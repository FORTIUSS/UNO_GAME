# UNO Card Game - Production-Ready Mobile Application

A scalable, real-time multiplayer UNO card game for iOS and Android built with Flutter, Node.js, and Firebase.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Backend Setup](#backend-setup)
- [Frontend Setup](#frontend-setup)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Troubleshooting](#troubleshooting)

## ✨ Features

### Core Gameplay
- **Full UNO Rules Implementation**: 112-card deck with 4 colors, number cards, action cards, and wild cards
- **Custom Blank Cards**: 4 special wild cards for custom rule definition
- **Complete UNO Call System**: Press button when 1 card remains; penalty for missed calls
- **Server-Side Validation**: All moves validated server-side to prevent cheating
- **Turn Management**: Clockwise default with Reverse card support (acts as Skip in 2-player)
- **Draw Mechanics**: Draw 1, must play immediately if valid; Draw Two, Draw Four with stacking support

### Multiplayer
- **2-10 Player Support**: Scalable lobbies with dynamic player management
- **Public Matchmaking**: Quick play with random opponents
- **Private Rooms**: Friends-only play with customizable rules
- **Room Codes**: Easy 6-character codes for room joining
- **Invite System**: Add friends and send room invitations

### Advanced Rules
- **House Rules**: Configurable stacking, jump-in, force play
- **Challenge System**: Verify Wild Draw Four legality with server-side validation
- **Action Cards**: Skip, Reverse, Draw Two with proper sequencing
- **Wild Color Selection**: Choose color after playing Wild/Wild Draw Four

### User Features
- **Authentication**: Guest login, email signup, Google/Apple sign-in
- **Profiles**: Customizable avatars, display names, and statistics
- **Friends List**: Add friends and filter games by friends
- **Match History**: View past games and statistics
- **Leaderboards**: Global and friend rankings
- **Achievements**: Unlock badges and track progress

### UI/UX
- **Mobile Optimized**: Responsive design for all screen sizes
- **Smooth Animations**: Card animations, turn transitions, visual feedback
- **Drag & Tap**: Intuitive card play mechanics
- **Sound Effects**: Optional audio feedback for actions
- **Haptic Feedback**: Tactile feedback on Android and iOS
- **Offline Support**: Graceful degradation for connection loss

### Technical
- **Real-Time Sync**: WebSocket-based state synchronization
- **Reconnection Handling**: Automatic reconnect with state restoration
- **Host Migration**: Game continues if host disconnects
- **Server-Side Game Logic**: Prevents client-side cheating
- **Scalable Architecture**: Supports thousands of concurrent rooms

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│           Flutter Mobile Apps                    │
│        (iOS & Android)                          │
└────────────────┬────────────────────────────────┘
                 │
         ┌───────┴────────┐
         │                │
    REST API         WebSocket (Socket.io)
         │                │
┌────────┴──────────────────────────────┐
│      Node.js Express Server            │
│  - Game Logic                          │
│  - Room Management                     │
│  - Authentication                      │
│  - Real-Time Events                    │
└────────┬──────────────────────────────┘
         │
    ┌────┴──────────┬──────────┐
    │               │          │
Firebase Auth  Firestore  Storage
    │               │          │
└───┴───────────────┴──────────┘
   Firebase Backend
```

## 🛠️ Requirements

### Client (Flutter)
- Flutter 3.0+
- Dart 3.0+
- iOS 12.0+ / Android 6.0+
- Xcode 14+ (for iOS)
- Android Studio 2022.1+ (for Android)

### Backend (Node.js)
- Node.js 16.0+
- npm 8.0+
- Firebase Project with Firestore, Auth, and Storage

### Development Tools
- Git
- Visual Studio Code or Android Studio
- Firebase CLI
- Xcode Command Line Tools (macOS)

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/uno-game.git
cd uno-game
```

### 2. Backend Setup (5 minutes)
```bash
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your Firebase credentials

# Start development server
npm run dev
# Server runs on http://localhost:3000
```

### 3. Frontend Setup (5 minutes)
```bash
cd flutter_app

# Get dependencies
flutter pub get

# Run on emulator/device
flutter run
```

## 📱 Backend Setup

### Step 1: Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Click "Add project"
   - Enable Firestore, Authentication, and Storage

2. **Configure Authentication**
   ```
   Firebase Console → Authentication → Sign-in method
   ✓ Enable: Email/Password
   ✓ Enable: Google
   ✓ Enable: Apple (iOS)
   ```

3. **Download Service Account Key**
   ```
   Firebase Console → Project Settings → Service Accounts
   → Generate new private key → Save as credentials.json
   ```

4. **Create Firestore Indexes**
   ```bash
   firebase firestore:indexes --project your-project-id
   ```

### Step 2: Environment Configuration

Create `.env` file in backend directory:

```env
NODE_ENV=production
PORT=3000
HOST=0.0.0.0

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-email@appspot.gserviceaccount.com
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com

# JWT
JWT_SECRET=your-super-secret-key-change-this
JWT_EXPIRATION=7d

# Game Configuration
MAX_PLAYERS_PER_ROOM=10
MIN_PLAYERS_TO_START=2
INITIAL_HAND_SIZE=7
GAME_INACTIVITY_TIMEOUT=300000

# CORS
ALLOWED_ORIGINS=https://uno-game.com,https://app.uno-game.com
```

### Step 3: Initialize Database Schema

```bash
# Apply Firestore security rules
firebase deploy --only firestore:rules

# Create collections
npm run db:init
```

### Step 4: Start Backend Server

```bash
# Development with hot reload
npm run dev

# Production build
npm run build
npm start
```

Server will be available at `http://localhost:3000`

## 📲 Frontend Setup

### Step 1: Flutter Configuration

```bash
cd flutter_app

# Get all dependencies
flutter pub get

# Generate JSON serialization code
flutter pub run build_runner build
```

### Step 2: Configure Firebase

1. **Android (flutter_app/android/app/build.gradle)**
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

2. **iOS (flutter_app/ios/Podfile)**
   ```ruby
   ios, :minVersion: '12.0'
   ```

3. **Add google-services.json and GoogleService-Info.plist**
   - Download from Firebase Console
   - Place in appropriate directories

### Step 3: Update Configuration

Edit `lib/utils/constants.dart`:

```dart
class AppConstants {
  static const String backendUrl = 'https://api.uno-game.com';
  static const String wsUrl = 'wss://api.uno-game.com';
  // ...
}
```

### Step 4: Run Application

```bash
# iOS
flutter run -d iphone

# Android
flutter run -d android-emulator

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release
```

## 🌐 Deployment

### Backend Deployment (Firebase Cloud Functions / Cloud Run)

#### Option A: Firebase Cloud Functions

```bash
cd backend

# Create functions project structure
firebase init functions

# Deploy functions
firebase deploy --only functions
```

#### Option B: Cloud Run

```bash
# Build Docker image
docker build -t uno-game-backend .

# Push to Container Registry
docker tag uno-game-backend gcr.io/PROJECT_ID/uno-game-backend
docker push gcr.io/PROJECT_ID/uno-game-backend

# Deploy to Cloud Run
gcloud run deploy uno-game-backend \
  --image gcr.io/PROJECT_ID/uno-game-backend \
  --platform managed \
  --region us-central1 \
  --set-env-vars NODE_ENV=production
```

#### Option C: Traditional Server (AWS EC2, DigitalOcean, etc.)

```bash
# SSH into server
ssh ubuntu@your-server.com

# Clone repo
git clone https://github.com/yourusername/uno-game.git
cd uno-game/backend

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 for process management
sudo npm install -g pm2

# Install dependencies
npm install --production

# Start with PM2
pm2 start src/index.ts --name "uno-game-backend"
pm2 startup
pm2 save

# Configure Nginx as reverse proxy
sudo apt-get install nginx

# Edit /etc/nginx/sites-available/default
# Add proxy settings pointing to localhost:3000
sudo systemctl restart nginx
```

### Frontend Deployment (App Stores)

#### Google Play Store

```bash
cd flutter_app

# Increase version
# Edit pubspec.yaml: version: 1.0.0+1

# Build release APK
flutter build appk --release --obfuscate --split-debug-info=build/app/outputs/symbols/

# Create app signing key
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048

# Configure signing in android/app/build.gradle
# Upload to Google Play Console
```

#### Apple App Store

```bash
cd flutter_app

# Build release bundle
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# Select appropriate development team
# Archive and submit to App Store Connect
```

## ⚙️ Configuration

### Game Rules Configuration

Example rules in room creation:

```javascript
{
  "allowStacking": true,      // +2 on +2, +4 on +4
  "allowJumpIn": true,        // Play identical cards instantly
  "allowForcePlay": false,    // Normal rules
  "allowCustomRules": true,   // Custom blank cards
  "startingHandSize": 7       // Standard UNO
}
```

### Scoring Modes

```javascript
// Single Round (cumulative hand scores)
"scoringMode": "singleRound"

// Cumulative (track across multiple rounds)
"scoringMode": "cumulative"
```

### Server Limits

```env
MAX_PLAYERS_PER_ROOM=10
MAX_CONCURRENT_ROOMS=1000
GAME_INACTIVITY_TIMEOUT=300000  # 5 minutes
RECONNECTION_GRACE_PERIOD=30000  # 30 seconds
```

## 📚 Documentation

- [API Documentation](./documentation/API_DOCUMENTATION.md)
- [Database Schema](./documentation/DATABASE_SCHEMA.md)
- [Architecture Guide](./documentation/ARCHITECTURE.md)
- [Game Rules](./documentation/GAME_RULES.md)

## 🔍 API Documentation

### Authentication
- `POST /api/auth/guest` - Guest login
- `POST /api/auth/signup` - Create account
- `POST /api/auth/signin` - Sign in
- `POST /api/auth/verify` - Verify token

### Rooms
- `POST /api/rooms` - Create room
- `GET /api/rooms` - List public rooms
- `GET /api/rooms/:roomId` - Get room details
- `POST /api/rooms/:roomId/join` - Join room
- `POST /api/rooms/:roomId/leave` - Leave room
- `POST /api/rooms/:roomId/start` - Start game

### Game
- `GET /api/game/rooms/:roomId/state` - Get game state
- `POST /api/game/rooms/:roomId/play-card` - Play card
- `POST /api/game/rooms/:roomId/draw-card` - Draw card
- `POST /api/game/rooms/:roomId/challenge` - Challenge move

### Users
- `GET /api/users/me` - Get profile
- `PUT /api/users/me` - Update profile
- `GET /api/users/me/stats` - Get statistics
- `GET /api/users/me/history` - Match history
- `GET /api/users/me/friends` - Friends list

See [API Documentation](./documentation/API_DOCUMENTATION.md) for complete details.

## 🗄️ Database Schema

See [Database Schema](./documentation/DATABASE_SCHEMA.md) for complete Firestore structure.

Key Collections:
- `users` - User profiles and account data
- `rooms` - Game rooms and matchmaking
- `games` - Active game states
- `matches` - Completed matches and history
- `stats` - Player statistics and leaderboards

## 🐛 Troubleshooting

### Backend Issues

**Port already in use**
```bash
# Find process using port 3000
lsof -i :3000
# Kill process
kill -9 <PID>
```

**Firebase connection error**
```bash
# Verify credentials in .env
cat .env | grep FIREBASE

# Test connection
curl http://localhost:3000/health
```

**WebSocket connection failing**
```bash
# Check CORS in backend/src/index.ts
# Ensure client URL is in ALLOWED_ORIGINS
```

### Frontend Issues

**Compilation errors**
```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build
```

**Firebase not initializing**
```bash
# Verify google-services.json exists
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
```

**WebSocket not connecting**
```dart
// Check backend URL in lib/utils/constants.dart
// Ensure WebSocket URL uses wss:// for HTTPS
```

## 📊 Monitoring

### Server Monitoring
```bash
# Monitor PM2 processes
pm2 monit

# View logs
pm2 logs uno-game-backend
```

### Firebase Monitoring
- Firestore: Firebase Console → Firestore Database
- Authentication: Firebase Console → Authentication
- Performance: Firebase Console → Performance Monitoring

## 🔐 Security

- ✅ Server-side validation for all game moves
- ✅ JWT token-based authentication
- ✅ Firestore security rules enforce access control
- ✅ CORS configured for production domains
- ✅ Rate limiting on API endpoints
- ✅ HTTPS/WSS for encrypted communication
- ✅ Input validation and sanitization
- ✅ No sensitive data in client-side code

## 📈 Scaling Considerations

- **Concurrent Rooms**: Current setup handles 1000+ rooms
- **Player Capacity**: 10 players per room, 10,000+ concurrent players
- **Database**: Firestore auto-scales; configure indexes for performance
- **WebSocket**: Socket.io can be clustered with Redis adapter
- **Load Balancing**: Use Cloud Load Balancer or Nginx

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📞 Support

For issues and questions:
- GitHub Issues: [GitHub Issues](https://github.com/yourusername/uno-game/issues)
- Email: support@uno-game.com
- Documentation: [Full Docs](./documentation/)

## 🙏 Acknowledgments

- UNO is a trademark of Mattel Inc.
- This is an educational project for demonstration purposes
- Built with Flutter, Node.js, Firebase, and Express

---

**Version**: 1.0.0  
**Last Updated**: February 2024  
**Maintained by**: Development Team
