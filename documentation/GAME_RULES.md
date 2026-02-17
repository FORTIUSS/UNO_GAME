# UNO Game - Complete Rules Documentation

## Game Overview

This is a digital implementation of the classic UNO card game with 2-10 players. The objective is to be the first player to play all cards from their hand.

## Card Deck (112 Cards Total)

### Colored Cards (4 Colors × 25 cards = 100 cards)
- **Red, Blue, Green, Yellow**
- Number cards: 0-9
  - One 0 card per color
  - Two of each 1-9 per color
- Action cards (2 each per color):
  - **Skip**: Skip the next player's turn
  - **Reverse**: Reverse direction (acts as Skip in 2-player)
  - **Draw Two (+2)**: Next player draws 2 cards and loses their turn

### Wild Cards (8 cards)
- **Wild (4 cards)**: Play on any card, choose a color for next player
- **Wild Draw Four (+4) (4 cards)**: Play on any card, choose color, next player draws 4 cards (challengeable)

### Custom Blank Cards (4 cards)
- **Custom Wild**: When played, define a special rule for that round
- Example: "Next player must play with left hand only"

## Setup

1. **Player Seating**: Arrange 2-10 players in a circle
2. **Dealer**: First dealer selected randomly or by agreement
3. **Dealing**: Each player gets 7 cards dealt face-down
4. **Draw Pile**: Remaining cards placed face-down as draw pile
5. **Discard Pile**: Top card from draw pile flipped to start discard pile
6. **Starting**: Player to dealer's left plays first (clockwise direction)

## Turn Sequence

### On Your Turn:
1. **Play a Card** (if possible):
   - From your hand, play a card matching the **color**, **number**, or **symbol** of the top card
   - OR play any **Wild** or **Wild Draw Four** card
   - Place played card on discard pile

2. **If No Valid Card**:
   - Draw one card from draw pile
   - If drawn card is playable, play it immediately
   - If not playable, turn ends

3. **Special Actions**:
   - Declare color when playing Wild cards
   - Call "UNO" when reducing hand to 1 card
   - Challenge Wild Draw Four if played illegally

### Play Validation (Server-Side)

The server validates:
- Card is in player's hand
- Card matches top discard card (color, number, or type)
- Wild card color declaration is provided
- Player has valid moves before drawing

## Card Effects

### Number Cards (0-9)
- Play on any card with same number or color
- No special effect
- Point value: Face value (0-9)

### Skip (S)
- Play on any card with same color
- Next player loses their turn
- Play passes to following player
- Point value: 20 points

### Reverse (R)
- Play on any card with same color
- Reverses game direction (clockwise ↔ counter-clockwise)
- In 2-player game: Acts as Skip
- Point value: 20 points

### Draw Two (+2)
- Play on any card with same color
- Next player draws 2 cards from draw pile
- Next player loses their turn
- With stacking: Can stack another +2 or +4 (if allowed)
- Point value: 20 points

### Wild (W)
- Can played on any card at any time
- After playing, declare a color
- Next player must play matching declared color
- Point value: 50 points

### Wild Draw Four (+4)
- **Restrictions**: Can only be played if you have NO cards matching current color
- Can played on any card
- Declare a color
- Next player draws 4 cards and loses turn
- **Challengeable**: Next player can challenge legality
- Point value: 50 points

### Custom Blank (C)
- Can be played as Wild card
- Declare a custom rule
- Examples:
  - "Play cards simultaneously for 3 turns"
  - "Next player plays with opposite hand"
  - "Add one card to hand limit"
- Point value: 50 points
- Server stores custom rule for round

## Advanced Rules

### UNO Call System

**When**: You have exactly 1 card remaining
**Action**: Press the "UNO" button
**Penalty**: 
- If caught without calling before next turn starts: Draw 2 cards
- Opponent can challenge after you call

### Challenge System

**Who Can Challenge**: 
- Player who received Wild Draw Four
- Challenger claims player illegally played +4

**Challenge Resolution**:
1. Server checks player's hand
2. If player had matching color card:
   - Challenge is VALID
   - Challenger receives penalty cards instead
   - Current player draws 2 cards
3. If player had no matching color:
   - Challenge is INVALID  
   - Challenger draws 6 additional cards (4 + 2 penalty)

### Direction System

**Clockwise** (Default):
- Play goes: Player 1 → 2 → 3 → etc.

**Counter-Clockwise** (After Reverse):
- Play goes: Player 3 → 2 → 1 → etc.

**2-Player Special Rule**:
- Reverse acts as Skip
- Only clockwise direction used

### Draw Pile Management

**When Draw Pile Empty**:
1. Discard pile (except top card) reshuffled
2. New draw pile created
3. Game continues

**If Both Empty**: 
- Game continues with no drawing (rare)

## House Rules (Optional)

### Stacking (+2 and +4)
**When Enabled**: 
- If someone plays +2 on you: You can play another +2 or +4
- Stacks accumulate (2, 4, 6, 8, etc. cards drawn)
- First player unable to stack must draw all accumulated cards

### Jump-In
**When Enabled**:
- If you hold an identical card to the card just played
- You can play immediately, even if not your turn
- Your turn comes as normal after jump-in card plays

### Force Play
**When Enabled**:
- Can play cards directly from hand if they match
- No need to wait for valid moves
- Regular UNO rules apply

### Custom Blank Rule Variations
- Can be played at any time
- Rule applies only to next X turns
- Server validates rule fairness

## Scoring

### Round Scoring
Points counted for cards remaining in player's hands:

| Card Type | Points |
|-----------|--------|
| Number 0-9 | Face Value |
| Skip | 20 |
| Reverse | 20 |
| Draw Two | 20 |
| Wild | 50 |
| Wild Draw Four | 50 |
| Custom Blank | 50 |

**Winning**: First to play all cards gets 0 points
**Losing**: Other players earn points for remaining cards

### Scoring Modes

**Single Round Mode**:
- Play one round
- Winner is player with lowest score
- Game ends

**Cumulative Mode**:
- Play multiple rounds
- Scores accumulate across rounds
- First to reach target score (usually 500) wins

## Winning Conditions

### Round Win
- First player to play all cards from hand
- Other players score points
- Continue to next round (cumulative mode)

### Game Win
- Single Round: Lowest score wins
- Cumulative: First to 500 points (or configured limit)

## Disconnection & Reconnection

**If Player Disconnects**:
- Game pauses for 30 seconds
- Other players see "Player Disconnected" status
- Player can reconnect to resume

**If Host Disconnects**:
- Game pauses
- New host elected from remaining players
- Game resumes with same state

**If Game Times Out**:
- After 5 minutes of no activity
- Game ends automatically
- Results recorded

## Game Events & Notifications

### Events Players See
- Player joined/left room
- Game started
- Card played (player, card type)
- Player drawn card (no card details shown)
- Player skipped/reversed
- UNO called
- Challenge issued/resolved
- Game ended with winner
- Score updates

## Technical Implementation Notes

### Server-Side Validation
- All moves validated server-side
- Game state maintained on server
- Clients cannot cheat (validated moves only)

### Real-Time Synchronization
- WebSocket events push updates to all players
- Card deals synchronized immediately
- Turn changes broadcast instantly

### Offline Handling
- Client caches last known game state
- Reconnection fetches complete state from server
- No moves processed during offline period

## Accessibility Features

- **Text Alternatives**: All colors have symbols
- **Sound Indicators**: Optional audio feedback for turns
- **Color Blind Mode**: High contrast colors available
- **Large Text Options**: Scalable UI
- **Haptic Feedback**: Vibration on card play

## Anti-Cheat Measures

1. **Server-Side Validation**: All moves verified server-side
2. **Game State Authority**: Server is source of truth
3. **Hand Privacy**: Cards only visible to owner
4. **Move Logging**: All actions logged for review
5. **Challenge Review**: Server re-validates challenges
6. **Rate Limiting**: Prevents action spam
7. **Timing Validation**: Checks action timing validity

## Common Situations

### "Can I play a Wild?"
Yes, anytime, even if you have valid moves.

### "Can I see other players' cards?"
No, only the discard pile top card and hand count visible.

### "What if I play wrong?"
Server validates; invalid moves rejected automatically.

### "How long can I think?"
No time limit, but server may timeout after 2 minutes.

### "Can I take back my card?"
No, once played and confirmed, move is final.

### "What if connection drops mid-turn?"
You can reconnect and resume turn with same hand.

## Tips for Winning

1. **Manage Color**: Track which colors are being played
2. **Watch Players**: Remember what colors others play
3. **Save Wilds**: Use Wild cards strategically
4. **Reverse Timing**: Use Reverse to skip strong players
5. **Call UNO**: Don't forget - penalty is costly
6. **Track Draws**: Remember what others drew
7. **Block Opponents**: Play cards preventing opponents' plays
8. **Final Push**: Save strong cards for endgame

## Game Balance

- **2 Players**: Reverse = Skip, all other rules standard
- **3-4 Players**: Standard rules, good balance
- **5-10 Players**: Longer rounds, more strategic
- **House Rules**: Can modify balance (stacking slows game)

## Version History

- **v1.0.0**: Initial release
  - Core UNO rules
  - 2-10 player support
  - Real-time multiplayer
  - Custom blank cards
  - Challenge system
  - Cumulative scoring
  - House rules support
