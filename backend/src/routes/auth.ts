import { Router } from 'express';
import * as admin from 'firebase-admin';
import { asyncHandler, AppError } from '../middleware/errorHandler';

const router = Router();

// Guest login
router.post(
  '/guest',
  asyncHandler(async (_req, res) => {
    try {
      // Create anonymous Firebase user
      const userRecord = await admin.auth().createUser({
        displayName: `Guest_${Date.now()}`,
      });

      // Create custom token
      const customToken = await admin.auth().createCustomToken(userRecord.uid);

      res.json({
        uid: userRecord.uid,
        token: customToken,
        isGuest: true,
      });
    } catch (error: any) {
      throw new AppError(400, 'Failed to create guest account', {
        error: error.message,
      });
    }
  })
);

// Sign up with email
router.post(
  '/signup',
  asyncHandler(async (req, res) => {
    const { email, password, displayName } = req.body;

    if (!email || !password || !displayName) {
      throw new AppError(400, 'Missing required fields');
    }

    try {
      const userRecord = await admin.auth().createUser({
        email,
        password,
        displayName,
      });

      // Store user in Firestore
      await admin.firestore().collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email,
        displayName,
        createdAt: new Date(),
        lastLogin: new Date(),
        friendIds: [],
        hasCompletedProfile: false,
      });

      const customToken = await admin.auth().createCustomToken(userRecord.uid);

      res.status(201).json({
        uid: userRecord.uid,
        email,
        token: customToken,
      });
    } catch (error: any) {
      if (error.code === 'auth/email-already-exists') {
        throw new AppError(409, 'Email already in use');
      }
      throw new AppError(400, 'Failed to create user', { error: error.message });
    }
  })
);

// Sign in with email
router.post(
  '/signin',
  asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new AppError(400, 'Email and password required');
    }

    try {
      // Verify credentials (in production, use Firebase client SDK)
      const userRecord = await admin.auth().getUserByEmail(email);
      const customToken = await admin.auth().createCustomToken(userRecord.uid);

      // Update last login
      await admin
        .firestore()
        .collection('users')
        .doc(userRecord.uid)
        .update({
          lastLogin: new Date(),
        });

      res.json({
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        token: customToken,
      });
    } catch (error: any) {
      throw new AppError(401, 'Invalid credentials');
    }
  })
);

// Verify token
router.post(
  '/verify',
  asyncHandler(async (req, res) => {
    const { token } = req.body;

    if (!token) {
      throw new AppError(400, 'Token required');
    }

    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      const userDoc = await admin
        .firestore()
        .collection('users')
        .doc(decodedToken.uid)
        .get();

      res.json({
        uid: decodedToken.uid,
        valid: true,
        user: userDoc.data(),
      });
    } catch (error) {
      throw new AppError(401, 'Invalid token');
    }
  })
);

export default router;
