import { Router } from 'express';
import * as admin from 'firebase-admin';
import { v4 as uuidv4 } from 'uuid';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../middleware/auth';
import { AppUtils } from '../utils/AppUtils';

const router = Router();

// Create new room
router.post(
  '/',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const {
      name,
      maxPlayers = 4,
      roomType = 'public',
      password,
      allowStacking = false,
      allowJumpIn = false,
      allowForcePlay = false,
    } = req.body;

    if (!name) {
      throw new AppError(400, 'Room name required');
    }

    if (maxPlayers < 2 || maxPlayers > 10) {
      throw new AppError(400, 'Max players must be between 2 and 10');
    }

    const roomId = uuidv4();
    const roomCode = AppUtils.generateRoomCode();
    const inviteLink = `https://uno-game.com/join/${roomCode}`;

    const roomData = {
      id: roomId,
      name,
      hostId: req.user!.uid,
      roomType,
      status: 'waiting',
      players: [
        {
          id: req.user!.uid,
          name: req.user!.displayName || 'Player',
          socketId: '',
          score: 0,
        },
      ],
      maxPlayers,
      roomCode,
      inviteLink,
      isPasswordProtected: !!password,
      rules: {
        allowStacking,
        allowJumpIn,
        allowForcePlay,
        startingHandSize: 7,
      },
      createdAt: new Date(),
      currentRound: 0,
      cumulativeScores: {},
    };

    // Store in Firestore
    await admin.firestore().collection('rooms').doc(roomId).set(roomData);

    res.status(201).json({
      roomId,
      ...roomData,
    });
  })
);

// Get room details
router.get(
  '/:roomId',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;

    const roomDoc = await admin.firestore().collection('rooms').doc(roomId).get();

    if (!roomDoc.exists) {
      throw new AppError(404, 'Room not found');
    }

    res.json(roomDoc.data());
  })
);

// List public rooms
router.get(
  '/',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const limit = Math.min(parseInt(req.query.limit as string) || 10, 50);
    const offset = parseInt(req.query.offset as string) || 0;

    const snapshot = await admin
      .firestore()
      .collection('rooms')
      .where('roomType', '==', 'public')
      .where('status', '==', 'waiting')
      .limit(limit)
      .offset(offset)
      .get();

    const rooms = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json(rooms);
  })
);

// Join room
router.post(
  '/:roomId/join',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;
    const { password } = req.body;

    const roomRef = admin.firestore().collection('rooms').doc(roomId);
    const roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      throw new AppError(404, 'Room not found');
    }

    const roomData = roomDoc.data()!;

    // Validate password if protected
    if (roomData.isPasswordProtected && roomData.password !== password) {
      throw new AppError(403, 'Invalid password');
    }

    // Check room full
    if (roomData.players.length >= roomData.maxPlayers) {
      throw new AppError(400, 'Room is full');
    }

    // Check if already in room
    if (roomData.players.some((p: any) => p.id === req.user!.uid)) {
      throw new AppError(400, 'Already in room');
    }

    // Add player
    const newPlayer = {
      id: req.user!.uid,
      name: req.user!.displayName || 'Player',
      socketId: '',
      score: 0,
    };

    await roomRef.update({
      players: [...roomData.players, newPlayer],
    });

    res.json({
      success: true,
      message: 'Joined room',
    });
  })
);

// Leave room
router.post(
  '/:roomId/leave',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;

    const roomRef = admin.firestore().collection('rooms').doc(roomId);
    const roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      throw new AppError(404, 'Room not found');
    }

    const roomData = roomDoc.data()!;
    const updatedPlayers = roomData.players.filter(
      (p: any) => p.id !== req.user!.uid
    );

    if (updatedPlayers.length === 0) {
      // Delete room if empty
      await roomRef.delete();
    } else {
      // Transfer host if needed
      const newHostId =
        roomData.hostId === req.user!.uid
          ? updatedPlayers[0].id
          : roomData.hostId;

      await roomRef.update({
        players: updatedPlayers,
        hostId: newHostId,
      });
    }

    res.json({ success: true });
  })
);

// Start game
router.post(
  '/:roomId/start',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { roomId } = req.params;

    const roomRef = admin.firestore().collection('rooms').doc(roomId);
    const roomDoc = await roomRef.get();

    if (!roomDoc.exists) {
      throw new AppError(404, 'Room not found');
    }

    const roomData = roomDoc.data()!;

    // Only host can start
    if (roomData.hostId !== req.user!.uid) {
      throw new AppError(403, 'Only host can start game');
    }

    // Need at least 2 players
    if (roomData.players.length < 2) {
      throw new AppError(400, 'Need at least 2 players to start');
    }

    await roomRef.update({
      status: 'active',
      startedAt: new Date(),
    });

    res.json({ success: true });
  })
);

export default router;
