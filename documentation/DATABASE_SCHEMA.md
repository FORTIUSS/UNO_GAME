# UNO Game - Database Schema

## Firestore Collections

### 1. `users` Collection
Stores user profile information and account data.

```
/users/{userId}
├── uid: string (primary key)
├── email: string
├── displayName: string
├── photoUrl: string (optional)
├── phoneNumber: string (optional)
├── isGuestUser: boolean
├── createdAt: timestamp
├── lastLogin: timestamp
├── friendIds: array<string>
├── hasCompletedProfile: boolean
└── customRules: map (optional)

Example:
{
  "uid": "user_123abc",
  "email": "player@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "isGuestUser": false,
  "createdAt": "2024-02-16T10:30:00Z",
  "lastLogin": "2024-02-16T14:45:00Z",
  "friendIds": ["user_456def", "user_789ghi"],
  "hasCompletedProfile": true
}
```

### 2. `rooms` Collection
Stores game room information and multiplayer sessions.

```
/rooms/{roomId}
├── id: string (primary key)
├── name: string
├── hostId: string (foreign key → users.uid)
├── roomType: enum (public | private)
├── status: enum (waiting | active | completed)
├── players: array<Player>
│   ├── id: string
│   ├── name: string
│   ├── socketId: string
│   ├── score: number
│   └── isConnected: boolean
├── maxPlayers: number
├── roomCode: string (unique, for private rooms)
├── inviteLink: string
├── isPasswordProtected: boolean
├── rules: map
│   ├── allowStacking: boolean (default: false)
│   ├── allowJumpIn: boolean (default: false)
│   ├── allowForcePlay: boolean (default: false)
│   ├── allowCustomRules: boolean (default: true)
│   └── startingHandSize: number (default: 7)
├── createdAt: timestamp
├── startedAt: timestamp (optional)
├── finishedAt: timestamp (optional)
├── currentRound: number
├── scoringMode: enum (singleRound | cumulative)
└── cumulativeScores: map<string, number>

Example:
{
  "id": "room_uuid",
  "name": "Game Night",
  "hostId": "user_123abc",
  "roomType": "private",
  "status": "active",
  "players": [
    {"id": "user_123abc", "name": "Host", "socketId": "socket_1", "score": 120, "isConnected": true},
    {"id": "user_456def", "name": "Player2", "socketId": "socket_2", "score": 85, "isConnected": true}
  ],
  "maxPlayers": 4,
  "roomCode": "ABC123",
  "inviteLink": "https://uno-game.com/join/ABC123",
  "isPasswordProtected": true,
  "rules": {
    "allowStacking": false,
    "allowJumpIn": true,
    "allowForcePlay": false,
    "allowCustomRules": true,
    "startingHandSize": 7
  },
  "createdAt": "2024-02-16T10:30:00Z",
  "startedAt": "2024-02-16T10:35:00Z",
  "currentRound": 1,
  "scoringMode": "cumulative",
  "cumulativeScores": {
    "user_123abc": 250,
    "user_456def": 185
  }
}
```

### 3. `games` Collection
Stores active game states for real-time synchronization.

```
/games/{roomId}
├── id: string
├── roomId: string (foreign key → rooms.id)
├── status: enum (waiting | inProgress | finished)
├── players: array<GamePlayer>
│   ├── id: string
│   ├── name: string
│   ├── socketId: string
│   ├── score: number
│   ├── hasCalledUno: boolean
│   └── isConnected: boolean
├── hands: map<string, array<Card>>
│   └── Card
│       ├── id: string
│       ├── color: enum (red | blue | green | yellow | wild)
│       ├── type: enum (number | skip | reverse | drawTwo | wild | wildDrawFour | customBlank)
│       ├── number: number (optional)
│       └── customRule: string (optional)
├── currentPlayerIndex: number
├── topCard: Card
├── discardPile: array<Card>
├── drawPile: array<Card>
├── direction: enum (clockwise | counterClockwise)
├── canChallenge: boolean
├── consecutiveDrawTwoCards: number
├── rules: map (reference to room rules)
├── createdAt: timestamp
├── finishedAt: timestamp (optional)
├── winnerId: string (optional, foreign key → users.uid)
└── roundScores: map<string, number> (optional)

Example:
{
  "id": "game_uuid",
  "roomId": "room_uuid",
  "status": "inProgress",
  "players": [...],
  "hands": {
    "user_123abc": [
      {"id": "card_1", "color": "red", "type": "number", "number": 5},
      {"id": "card_2", "color": "blue", "type": "skip"},
      ...
    ]
  },
  "currentPlayerIndex": 0,
  "topCard": {"id": "card_3", "color": "green", "type": "number", "number": 7},
  "discardPile": [...],
  "drawPile": [...],
  "direction": "clockwise",
  "canChallenge": false,
  "consecutiveDrawTwoCards": 0,
  "createdAt": "2024-02-16T10:35:00Z"
}
```

### 4. `matches` Collection
Stores historical match data for statistics and analytics.

```
/matches/{matchId}
├── id: string (primary key)
├── roomId: string (foreign key → rooms.id)
├── playerIds: array<string>
├── winnerId: string (foreign key → users.uid)
├── playerScores: map<string, number>
├── rounds: number
├── duration: number (minutes)
├── createdAt: timestamp
├── finishedAt: timestamp
├── gameMode: enum (public | private | quickPlay)
├── rules: map
└── playerStats: map<string, PlayerMatchStats>
    ├── cardsPlayed: number
    ├── cardsDrawn: number
    ├── unoCalledCorrectly: number
    ├── challengesIssued: number
    └── challengesWon: number

Example:
{
  "id": "match_uuid",
  "roomId": "room_uuid",
  "playerIds": ["user_123abc", "user_456def", "user_789ghi"],
  "winnerId": "user_123abc",
  "playerScores": {
    "user_123abc": 0,
    "user_456def": 85,
    "user_789ghi": 120
  },
  "rounds": 1,
  "duration": 15,
  "createdAt": "2024-02-16T10:35:00Z",
  "finishedAt": "2024-02-16T10:50:00Z",
  "gameMode": "private",
  "playerStats": {
    "user_123abc": {
      "cardsPlayed": 32,
      "cardsDrawn": 8,
      "unoCalledCorrectly": 1,
      "challengesIssued": 0,
      "challengesWon": 0
    }
  }
}
```

### 5. `stats` Collection
Stores aggregated player statistics.

```
/stats/{userId}
├── playerId: string (primary key, foreign key → users.uid)
├── totalGamesPlayed: number
├── totalWins: number
├── totalLosses: number
├── totalScore: number
├── winRate: number (percentage)
├── averageScorePerGame: number
├── bestWinScore: number
├── currentWinStreak: number
├── longestWinStreak: number
├── unoCallSuccess: number
├── unoCallMisses: number
├── challengesWon: number
├── challengesLost: number
├── favoriteColor: enum
├── lastUpdated: timestamp
└── badges: array<string> (achievement badges)
```

### 6. `invites` Collection
Stores friend and room invitations.

```
/invites/{inviteId}
├── id: string (primary key)
├── type: enum (friend | room)
├── fromUserId: string (foreign key → users.uid)
├── toUserId: string (foreign key → users.uid)
├── roomId: string (optional, foreign key → rooms.id)
├── status: enum (pending | accepted | declined | expired)
├── createdAt: timestamp
├── expiresAt: timestamp
└── respondedAt: timestamp (optional)
```

### 7. `activity_logs` Collection (Optional)
Stores game activity logs for moderation and analytics.

```
/activity_logs/{logId}
├── id: string
├── roomId: string
├── userId: string
├── action: string
├── details: map
└── timestamp: timestamp
```

## Database Indexes

### Recommended Composite Indexes

1. **Rooms Collection**
   - `roomType` + `status` + `createdAt` (for room listing)
   - `hostId` + `status` (for user's rooms)

2. **Matches Collection**
   - `playerIds` (array) + `finishedAt` (for player history)
   - `winnerId` + `finishedAt` (for win history)

3. **Stats Collection**
   - `winRate` DESC (for leaderboards)
   - `totalGamesPlayed` DESC (for experienced players)

4. **Users Collection**
   - `displayName` (for search)
   - `lastLogin` DESC (for active users)

## Security Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Rooms - public read, controlled write
    match /rooms/{roomId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      (get(/databases/$(database)/documents/rooms/$(roomId)).data.hostId == request.auth.uid ||
                       request.auth.uid in get(/databases/$(database)/documents/rooms/$(roomId)).data.players);
    }

    // Games - only room participants
    match /games/{gameId} {
      allow read, write: if request.auth != null &&
                            request.auth.uid in get(/databases/$(database)/documents/games/$(gameId)).data.playerIds;
    }

    // Matches - public read, no direct write
    match /matches/{matchId} {
      allow read: if true;
      allow write: if false; // Only server functions
    }

    // Stats - public read, no direct write
    match /stats/{userId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

## Data Flow Relationships

```
User
├── owns multiple Rooms (hostId)
├── participates in Rooms (players array)
├── participates in Games (playerIds)
├── has Stats entry
├── receives Invites
└── plays Matches

Room
├── contains Players
├── has active Game
├── generates Match on completion
├── belongs to User (host)
└── has Rules

Game
├── references Room
├── manages Hands (cards per player)
├── has one TopCard
├── tracks current Player
└── ends with Match result

Match
├── references Room and Players
├── records final Scores
├── stores PlayerStats
└── updates User Stats
```

## Backup and Retention Policies

- **User Data**: 7-year retention (regulatory compliance)
- **Match Data**: 2-year retention for statistics
- **Active Games**: Purge after 7 days of inactivity
- **Daily Backups**: Automated to Cloud Storage
- **Point-in-time Recovery**: Available for 30 days
