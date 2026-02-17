# UNO Game - API Documentation

## Base URL
- Development: `http://localhost:3000/api`
- Production: `https://api.uno-game.com/api`

## Authentication

All endpoints (except `/auth`) require authentication via Bearer token in the `Authorization` header:

```
Authorization: Bearer <firebase_id_token>
```

## Error Response Format

```json
{
  "error": "Error message",
  "details": {}
}
```

HTTP Status Codes:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `409`: Conflict
- `500`: Internal Server Error

---

## Authentication Endpoints

### POST /auth/guest
Guest login without authentication.

**Request:**
```json
{}
```

**Response (201):**
```json
{
  "uid": "user_123",
  "token": "firebase_custom_token",
  "isGuest": true
}
```

---

### POST /auth/signup
Create new user account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "secure_password",
  "displayName": "Player Name"
}
```

**Response (201):**
```json
{
  "uid": "user_123",
  "email": "user@example.com",
  "token": "firebase_custom_token"
}
```

**Errors:**
- `409`: Email already in use

---

### POST /auth/signin
Sign in with email and password.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

**Response (200):**
```json
{
  "uid": "user_123",
  "email": "user@example.com",
  "displayName": "Player Name",
  "token": "firebase_custom_token"
}
```

---

### POST /auth/verify
Verify authentication token.

**Request:**
```json
{
  "token": "firebase_id_token"
}
```

**Response (200):**
```json
{
  "uid": "user_123",
  "valid": true,
  "user": {
    "uid": "user_123",
    "displayName": "Player Name",
    "email": "user@example.com"
  }
}
```

---

## Room Management Endpoints

### POST /rooms
Create a new game room.

**Request:**
```json
{
  "name": "Game Night",
  "maxPlayers": 4,
  "roomType": "private",
  "password": "optional_password",
  "allowStacking": false,
  "allowJumpIn": true,
  "allowForcePlay": false
}
```

**Response (201):**
```json
{
  "roomId": "room_uuid",
  "roomCode": "ABC123",
  "inviteLink": "https://uno-game.com/join/ABC123",
  "name": "Game Night",
  "hostId": "user_123",
  "status": "waiting",
  "players": [
    {
      "id": "user_123",
      "name": "Host",
      "socketId": "",
      "score": 0
    }
  ],
  "maxPlayers": 4,
  "createdAt": "2024-02-16T10:30:00Z"
}
```

---

### GET /rooms
List public rooms.

**Query Parameters:**
- `limit` (number, default: 10, max: 50): Number of rooms to return
- `offset` (number, default: 0): Offset for pagination

**Response (200):**
```json
[
  {
    "id": "room_uuid",
    "name": "Game Night",
    "hostId": "user_123",
    "status": "waiting",
    "players": [],
    "maxPlayers": 4,
    "createdAt": "2024-02-16T10:30:00Z"
  }
]
```

---

### GET /rooms/:roomId
Get room details.

**Response (200):**
```json
{
  "id": "room_uuid",
  "name": "Game Night",
  "hostId": "user_123",
  "status": "waiting",
  "players": [
    {
      "id": "user_123",
      "name": "Host",
      "socketId": "socket_1",
      "score": 0
    }
  ],
  "maxPlayers": 4,
  "roomCode": "ABC123",
  "inviteLink": "https://uno-game.com/join/ABC123",
  "rules": {
    "allowStacking": false,
    "allowJumpIn": true
  },
  "createdAt": "2024-02-16T10:30:00Z"
}
```

---

### POST /rooms/:roomId/join
Join an existing room.

**Request:**
```json
{
  "password": "optional_password"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Joined room"
}
```

**Errors:**
- `404`: Room not found
- `400`: Room is full or already joined
- `403`: Invalid password

---

### POST /rooms/:roomId/leave
Leave a room.

**Response (200):**
```json
{
  "success": true
}
```

---

### POST /rooms/:roomId/start
Start the game (host only).

**Response (200):**
```json
{
  "success": true
}
```

**Errors:**
- `403`: Only host can start
- `400`: Need at least 2 players

---

## User Endpoints

### GET /users/me
Get current user profile.

**Response (200):**
```json
{
  "uid": "user_123",
  "email": "user@example.com",
  "displayName": "Player Name",
  "photoUrl": "https://...",
  "isGuestUser": false,
  "createdAt": "2024-02-16T10:30:00Z",
  "lastLogin": "2024-02-16T14:45:00Z",
  "friendIds": ["user_456", "user_789"],
  "hasCompletedProfile": true
}
```

---

### PUT /users/me
Update user profile.

**Request:**
```json
{
  "displayName": "New Name",
  "photoUrl": "https://...",
  "phoneNumber": "+1234567890"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profile updated"
}
```

---

### GET /users/me/stats
Get user statistics.

**Response (200):**
```json
{
  "playerId": "user_123",
  "totalGamesPlayed": 25,
  "totalWins": 12,
  "totalLosses": 13,
  "totalScore": 1250,
  "winRate": 48.0,
  "averageScorePerGame": 50.0,
  "bestWinScore": 150,
  "currentWinStreak": 2,
  "longestWinStreak": 5
}
```

---

### GET /users/me/history
Get user's match history.

**Query Parameters:**
- `limit` (number, default: 10, max: 50)

**Response (200):**
```json
[
  {
    "id": "match_uuid",
    "roomId": "room_uuid",
    "winnerId": "user_123",
    "playerScores": {
      "user_123": 0,
      "user_456": 85
    },
    "duration": 12,
    "finishedAt": "2024-02-16T10:50:00Z"
  }
]
```

---

### GET /users/me/friends
Get user's friends list.

**Response (200):**
```json
[
  {
    "id": "user_456",
    "displayName": "Friend Name",
    "photoUrl": "https://...",
    "isOnline": true
  }
]
```

---

### POST /users/me/friends/:friendId
Add a friend.

**Response (200):**
```json
{
  "success": true
}
```

**Errors:**
- `400`: Cannot add yourself
- `404`: Friend not found

---

### DELETE /users/me/friends/:friendId
Remove a friend.

**Response (200):**
```json
{
  "success": true
}
```

---

### GET /users/search
Search for users.

**Query Parameters:**
- `q` (string, min: 2 chars): Search query

**Response (200):**
```json
[
  {
    "id": "user_123",
    "displayName": "Player Name",
    "photoUrl": "https://..."
  }
]
```

---

## Game Endpoints

### GET /game/rooms/:roomId/state
Get current game state.

**Response (200):**
```json
{
  "id": "game_uuid",
  "roomId": "room_uuid",
  "status": "inProgress",
  "players": [...],
  "hands": {...},
  "currentPlayerIndex": 0,
  "topCard": {...},
  "direction": "clockwise"
}
```

---

### POST /game/rooms/:roomId/play-card
Play a card (server-validated).

**Request:**
```json
{
  "cardId": "card_uuid",
  "declaredColor": "red"
}
```

**Response (200):**
```json
{
  "success": true,
  "gameState": {...}
}
```

**Errors:**
- `403`: Not your turn
- `400`: Card not in hand or invalid move

---

### POST /game/rooms/:roomId/draw-card
Draw a card.

**Response (200):**
```json
{
  "success": true,
  "drawnCard": {
    "id": "card_uuid",
    "color": "blue",
    "type": "number",
    "number": 5
  }
}
```

---

### POST /game/rooms/:roomId/challenge
Challenge a Wild Draw Four (server-validated).

**Request:**
```json
{
  "targetPlayerId": "user_456"
}
```

**Response (200):**
```json
{
  "success": true,
  "challengeResult": "valid"
}
```

---

## WebSocket Events

### Connection
```javascript
socket.emit('join-room', {
  roomId: 'room_uuid',
  playerId: 'user_123',
  playerName: 'Player Name'
}, (response) => {
  // response.success, response.room
});
```

### Listeners
```javascript
socket.on('player-joined', (data) => {
  // data: { playerId, playerName, totalPlayers }
});

socket.on('card-played', (data) => {
  // data: { playerId, card, declaredColor, newHandSize }
});

socket.on('card-drawn', (data) => {
  // data: { playerId, newHandSize }
});

socket.on('uno-called', (data) => {
  // data: { playerId, playerName }
});

socket.on('game-started', (data) => {
  // data: { gameState, currentPlayer }
});

socket.on('player-disconnected', (data) => {
  // data: { playerId }
});
```

---

## Rate Limiting

- Default: 100 requests per 15 minutes
- Applies to: `/api/*` endpoints
- Returns: `429 Too Many Requests`

## CORS

- Development: http://localhost:*
- Production: https://uno-game.com
- WebSocket: Enabled with credentials

## HTTP Status Reference

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 429 | Too Many Requests |
| 500 | Internal Server Error |
