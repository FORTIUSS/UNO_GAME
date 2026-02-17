import { Router } from 'express';
import * as admin from 'firebase-admin';
import { asyncHandler, AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../middleware/auth';

const router = Router();

// Get user profile
router.get(
  '/me',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(req.user!.uid)
      .get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found');
    }

    res.json(userDoc.data());
  })
);

// Update user profile
router.put(
  '/me',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { displayName, photoUrl, phoneNumber } = req.body;

    const updateData: Record<string, any> = {};
    if (displayName) updateData.displayName = displayName;
    if (photoUrl) updateData.photoUrl = photoUrl;
    if (phoneNumber) updateData.phoneNumber = phoneNumber;
    updateData.hasCompletedProfile = true;

    await admin
      .firestore()
      .collection('users')
      .doc(req.user!.uid)
      .update(updateData);

    res.json({
      success: true,
      message: 'Profile updated',
    });
  })
);

// Get user stats
router.get(
  '/me/stats',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const statsDoc = await admin
      .firestore()
      .collection('stats')
      .doc(req.user!.uid)
      .get();

    if (!statsDoc.exists) {
      res.json({
        playerId: req.user!.uid,
        totalGamesPlayed: 0,
        totalWins: 0,
        totalLosses: 0,
        totalScore: 0,
        winRate: 0,
      });
      return;
    }

    res.json(statsDoc.data());
  })
);

// Get user match history
router.get(
  '/me/history',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const limit = Math.min(parseInt(req.query.limit as string) || 10, 50);

    const snapshot = await admin
      .firestore()
      .collection('matches')
      .where('playerIds', 'array-contains', req.user!.uid)
      .orderBy('finishedAt', 'desc')
      .limit(limit)
      .get();

    const history = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json(history);
  })
);

// Get friends list
router.get(
  '/me/friends',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(req.user!.uid)
      .get();

    const friendIds = userDoc.data()?.friendIds || [];

    if (friendIds.length === 0) {
      res.json([]);
      return;
    }

    const friends: any[] = [];
    for (const friendId of friendIds) {
      const friendDoc = await admin
        .firestore()
        .collection('users')
        .doc(friendId)
        .get();
      if (friendDoc.exists) {
        friends.push({
          id: friendDoc.id,
          ...friendDoc.data(),
        });
      }
    }

    res.json(friends);
  })
);

// Add friend
router.post(
  '/me/friends/:friendId',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { friendId } = req.params;

    if (friendId === req.user!.uid) {
      throw new AppError(400, 'Cannot add yourself');
    }

    // Check friend exists
    const friendDoc = await admin
      .firestore()
      .collection('users')
      .doc(friendId)
      .get();

    if (!friendDoc.exists) {
      throw new AppError(404, 'Friend not found');
    }

    // Add to friendIds list
    const userRef = admin.firestore().collection('users').doc(req.user!.uid);
    await userRef.update({
      friendIds: admin.firestore.FieldValue.arrayUnion(friendId),
    });

    res.json({ success: true });
  })
);

// Remove friend
router.delete(
  '/me/friends/:friendId',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { friendId } = req.params;

    const userRef = admin.firestore().collection('users').doc(req.user!.uid);
    await userRef.update({
      friendIds: admin.firestore.FieldValue.arrayRemove(friendId),
    });

    res.json({ success: true });
  })
);

// Search users
router.get(
  '/search',
  asyncHandler(async (req: AuthenticatedRequest, res) => {
    const { q } = req.query;

    if (!q || (q as string).length < 2) {
      throw new AppError(400, 'Query must be at least 2 characters');
    }

    const snapshot = await admin
      .firestore()
      .collection('users')
      .where('displayName', '>=', q)
      .where('displayName', '<=', (q as string) + '\uf8ff')
      .limit(20)
      .get();

    const users = snapshot.docs.map((doc) => ({
      id: doc.id,
      displayName: doc.data().displayName,
      photoUrl: doc.data().photoUrl,
    }));

    res.json(users);
  })
);

export default router;
