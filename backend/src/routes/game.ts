import { Router } from 'express';
import * as admin from 'firebase-admin';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../middleware/auth';
import { GameEngine } from '../services/GameEngine';

const router = Router();

// Get game state
router.get(
  '/rooms/:roomId/state',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;

    const gameDoc = await admin
      .firestore()
      .collection('games')
      .doc(roomId)
      .get();

    if (!gameDoc.exists) {
      throw new AppError(404, 'Game not found');
    }

    res.json(gameDoc.data());
  })
);

// Validate and play card (server-side validation)
router.post(
  '/rooms/:roomId/play-card',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;
    const { cardId, declaredColor } = req.body;

    const gameDoc = await admin
      .firestore()
      .collection('games')
      .doc(roomId)
      .get();

    if (!gameDoc.exists) {
      throw new AppError(404, 'Game not found');
    }

    const gameData = gameDoc.data()!;

    // Verify it's player's turn
    const currentPlayer = gameData.players[gameData.currentPlayerIndex];
    if (currentPlayer.id !== req.user!.uid) {
      throw new AppError(403, 'Not your turn');
    }

    // Get card from hand
    const playerHand = gameData.hands[req.user!.uid];
    const card = playerHand.find((c: any) => c.id === cardId);

    if (!card) {
      throw new AppError(400, 'Card not in hand');
    }

    // Server-validated move legality
    const isValid = GameEngine.isValidMove(
      card,
      gameData.topCard,
      declaredColor || null
    );

    if (!isValid) {
      throw new AppError(400, 'Invalid move');
    }

    // Update game state
    const updatedHand = playerHand.filter((c: any) => c.id !== cardId);
    const newGameData: any = {
      ...gameData,
      hands: {
        ...gameData.hands,
        [req.user!.uid]: updatedHand,
      },
      topCard: card,
      lastPlayedCard: card,
      lastPlayedBy: req.user!.uid,
    };

    // Check for round win
    if (updatedHand.length === 0) {
      newGameData.status = 'finished';
      newGameData.winnerId = req.user!.uid;
      newGameData.finishedAt = new Date();

      // Calculate scores
      const scores: Record<string, number> = {};
      const allHands = newGameData.hands;
      for (const [playerId, hand] of Object.entries(allHands)) {
        if (playerId === req.user!.uid) {
          scores[playerId] = 0;
        } else {
          scores[playerId] = GameEngine.calculateHandScore(hand as any);
        }
      }
      newGameData.roundScores = scores;
    }

    await admin.firestore().collection('games').doc(roomId).update(newGameData);

    res.json({
      success: true,
      gameState: newGameData,
    });
  })
);

// Draw card (server-side)
router.post(
  '/rooms/:roomId/draw-card',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;

    const gameDoc = await admin
      .firestore()
      .collection('games')
      .doc(roomId)
      .get();

    if (!gameDoc.exists) {
      throw new AppError(404, 'Game not found');
    }

    const gameData = gameDoc.data()!;

    // Verify it's player's turn
    const currentPlayer = gameData.players[gameData.currentPlayerIndex];
    if (currentPlayer.id !== req.user!.uid) {
      throw new AppError(403, 'Not your turn');
    }

    // Handle empty draw pile
    if (!gameData.drawPile || gameData.drawPile.length === 0) {
      if (gameData.discardPile.length <= 1) {
        throw new AppError(400, 'No more cards available');
      }
      // Reshuffle
      gameData.drawPile = GameEngine.shuffleDeck(
        gameData.discardPile.slice(0, -1)
      );
      gameData.discardPile = [gameData.topCard];
    }

    const drawnCard = gameData.drawPile.pop();
    const playerHand = gameData.hands[req.user!.uid];

    const newGameData = {
      ...gameData,
      hands: {
        ...gameData.hands,
        [req.user!.uid]: [...playerHand, drawnCard],
      },
    };

    await admin.firestore().collection('games').doc(roomId).update(newGameData);

    res.json({
      success: true,
      drawnCard,
    });
  })
);

// Challenge Wild Draw Four
router.post(
  '/rooms/:roomId/challenge',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;
    const { targetPlayerId } = req.body;

    const gameDoc = await admin
      .firestore()
      .collection('games')
      .doc(roomId)
      .get();

    if (!gameDoc.exists) {
      throw new AppError(404, 'Game not found');
    }

    const gameData = gameDoc.data()!;

    // Get target player's hand
    const targetHand = gameData.hands[targetPlayerId];
    const topCard = gameData.topCard;

    // Verify Wild Draw Four was played
    if (topCard.type !== 'wildDrawFour') {
      throw new AppError(400, 'Can only challenge Wild Draw Four');
    }

    // Server validates legality
    const isLegal = GameEngine.isWildDrawFourLegal(
      targetHand,
      topCard.declaredColor
    );

    if (isLegal) {
      // Challenge failed - challenger draws 4 cards
      throw new AppError(400, 'Invalid challenge - you must draw 4 cards');
    }

    // Challenge succeeded - target player draws 4 cards
    const newGameData = {
      ...gameData,
      // Apply challenge penalties
    };

    await admin.firestore().collection('games').doc(roomId).update(newGameData);

    res.json({
      success: true,
      challengeResult: 'valid',
    });
  })
);

// Get room statistics
router.get(
  '/statistics/room/:roomId',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;

    const matchesSnapshot = await admin
      .firestore()
      .collection('matches')
      .where('roomId', '==', roomId)
      .get();

    const stats = {
      totalMatches: matchesSnapshot.size,
      completed: matchesSnapshot.docs.filter((d) => d.data().status === 'finished').length,
    };

    res.json(stats);
  })
);

export default router;
