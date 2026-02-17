import { Socket, Server as SocketIOServer } from 'socket.io';
import { Logger } from 'pino';
import { GameEngine } from '../services/GameEngine';

interface RoomData {
  id: string;
  players: Map<string, string>; // playerId -> socketId
  gameState: any;
  createdAt: Date;
}

// Store active rooms in memory (for production, use Redis)
const activeRooms = new Map<string, RoomData>();

export function setupSocketHandlers(
  socket: Socket,
  io: SocketIOServer,
  logger: Logger
) {
  // Join room
  socket.on('join-room', async (data: any, callback: any) => {
    try {
      const { roomId, playerId, playerName } = data;
      logger.info(`Player ${playerId} joining room ${roomId}`);

      let room = activeRooms.get(roomId);
      if (!room) {
        room = {
          id: roomId,
          players: new Map(),
          gameState: null,
          createdAt: new Date(),
        };
        activeRooms.set(roomId, room);
      }

      // Add player to room
      room.players.set(playerId, socket.id);
      socket.join(roomId);
      socket.data.roomId = roomId;
      socket.data.playerId = playerId;
      socket.data.playerName = playerName;

      // Notify other players
      io.to(roomId).emit('player-joined', {
        playerId,
        playerName,
        totalPlayers: room.players.size,
      });

      callback({
        success: true,
        room: {
          id: roomId,
          players: Array.from(room.players.entries()).map(([id, socketId]) => ({
            id,
            socketId,
          })),
        },
      });
    } catch (error) {
      logger.error('Error joining room:', error);
      callback({ success: false, error: 'Failed to join room' });
    }
  });

  // Play card
  socket.on('play-card', async (data: any, callback: any) => {
    try {
      const { roomId, playerId, cardId, declaredColor } = data;
      const room = activeRooms.get(roomId);

      if (!room) {
        callback({ success: false, error: 'Room not found' });
        return;
      }

      // Server-side validation
      const playerHand = room.gameState?.hands?.[playerId];
      const topCard = room.gameState?.topCard;

      const card = playerHand?.find((c: any) => c.id === cardId);
      if (!card) {
        callback({ success: false, error: 'Card not in player hand' });
        return;
      }

      // Validate move
      const isValid = GameEngine.isValidMove(
        card,
        topCard,
        declaredColor || null
      );

      if (!isValid) {
        callback({ success: false, error: 'Invalid move' });
        return;
      }

      // Update game state
      const newHand = playerHand.filter((c: any) => c.id !== cardId);
      room.gameState.hands[playerId] = newHand;
      room.gameState.topCard = card;

      // Check UNO condition
      if (newHand.length === 1) {
        io.to(roomId).emit('uno-alert', {
          playerId,
          message: `${socket.data.playerName} has 1 card left!`,
        });
      }

      // Emit to all players
      io.to(roomId).emit('card-played', {
        playerId,
        card,
        declaredColor,
        newHandSize: newHand.length,
      });

      callback({ success: true });
    } catch (error) {
      logger.error('Error playing card:', error);
      callback({ success: false, error: 'Failed to play card' });
    }
  });

  // Draw card
  socket.on('draw-card', async (data: any, callback: any) => {
    try {
      const { roomId, playerId } = data;
      const room = activeRooms.get(roomId);

      if (!room || !room.gameState) {
        callback({ success: false, error: 'Room not found' });
        return;
      }

      // Server validates draw pile availability
      if (room.gameState.drawPile.length === 0) {
        // Reshuffle discard pile
        room.gameState.drawPile = room.gameState.discardPile.slice(0, -1);
        room.gameState.discardPile = [];
      }

      const drawnCard = room.gameState.drawPile.pop();
      room.gameState.hands[playerId].push(drawnCard);

      io.to(roomId).emit('card-drawn', {
        playerId,
        newHandSize: room.gameState.hands[playerId].length,
      });

      callback({ success: true, card: drawnCard });
    } catch (error) {
      logger.error('Error drawing card:', error);
      callback({ success: false, error: 'Failed to draw card' });
    }
  });

  // Call UNO
  socket.on('call-uno', async (data: any, callback: any) => {
    try {
      const { roomId, playerId } = data;
      const room = activeRooms.get(roomId);

      if (!room) {
        callback({ success: false, error: 'Room not found' });
        return;
      }

      const handSize = room.gameState?.hands?.[playerId]?.length || 0;

      if (handSize !== 1) {
        callback({ success: false, error: 'Cannot call UNO' });
        return;
      }

      room.gameState.players[playerId].hasCalledUno = true;

      io.to(roomId).emit('uno-called', {
        playerId,
        playerName: socket.data.playerName,
      });

      callback({ success: true });
    } catch (error) {
      logger.error('Error calling UNO:', error);
      callback({ success: false, error: 'Failed to call UNO' });
    }
  });

  // Challenge move
  socket.on('challenge', async (data: any, callback: any) => {
    try {
      const { roomId, challengerId, targetPlayerId } = data;
      const room = activeRooms.get(roomId);

      if (!room) {
        callback({ success: false, error: 'Room not found' });
        return;
      }

      // Server validates the challenge
      const targetHand = room.gameState?.hands?.[targetPlayerId];
      const topCard = room.gameState?.topCard;

      // Logic to determine if challenge is valid
      const challengeValid = targetHand && topCard;

      io.to(roomId).emit('challenge-result', {
        challengerId,
        targetPlayerId,
        valid: challengeValid,
      });

      callback({ success: true });
    } catch (error) {
      logger.error('Error challenging:', error);
      callback({ success: false, error: 'Failed to challenge' });
    }
  });

  // Start game
  socket.on('start-game', async (data: any, callback: any) => {
    try {
      const { roomId } = data;
      const room = activeRooms.get(roomId);

      if (!room || room.players.size < 2) {
        callback({ success: false, error: 'Not enough players' });
        return;
      }

      // Create initial game state
      const deck = GameEngine.createDeck();
      const shuffledDeck = GameEngine.shuffleDeck(deck);
      const playerIds = Array.from(room.players.keys());

      // Initialize game state with server-side validation
      room.gameState = {
        deck: shuffledDeck,
        hands: new Map(),
        players: playerIds.map((id) => ({
          id,
          hasCalledUno: false,
          score: 0,
        })),
        currentPlayerIndex: 0,
        topCard: null,
        direction: 'clockwise',
        startedAt: new Date(),
      };

      // Deal hands
      const hands = GameEngine.dealInitialHands(deck, playerIds.length);
      room.gameState.hands = Object.fromEntries(hands);

      io.to(roomId).emit('game-started', {
        gameState: room.gameState,
        currentPlayer: playerIds[0],
      });

      callback({ success: true });
    } catch (error) {
      logger.error('Error starting game:', error);
      callback({ success: false, error: 'Failed to start game' });
    }
  });

  // Leave room
  socket.on('leave-room', async (data: any) => {
    try {
      const { roomId } = data;
      const room = activeRooms.get(roomId);

      if (room) {
        room.players.delete(socket.data.playerId);

        if (room.players.size === 0) {
          activeRooms.delete(roomId);
        } else {
          io.to(roomId).emit('player-left', {
            playerId: socket.data.playerId,
            playerName: socket.data.playerName,
            remainingPlayers: room.players.size,
          });
        }
      }

      socket.leave(roomId);
    } catch (error) {
      logger.error('Error leaving room:', error);
    }
  });

  // Disconnect
  socket.on('disconnect', () => {
    logger.info(`Socket disconnected: ${socket.id}`);
    const roomId = socket.data.roomId;
    if (roomId) {
      const room = activeRooms.get(roomId);
      if (room) {
        room.players.delete(socket.data.playerId);
        if (room.players.size === 0) {
          activeRooms.delete(roomId);
        } else {
          io.to(roomId).emit('player-disconnected', {
            playerId: socket.data.playerId,
          });
        }
      }
    }
  });
}
