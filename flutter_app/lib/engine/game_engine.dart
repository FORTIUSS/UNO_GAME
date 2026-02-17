import 'package:uno_game/models/card_model.dart';

class GameEngine {
  /// Check if a card can be played on the discard pile
  static bool isValidMove(Card card, Card? topCard, CardColor? activeColor) {
    if (topCard == null) return true;

    // Wild cards can always be played
    if (card.color == CardColor.wild) {
      return true;
    }

    // Check color match (for wild cards that chose a color)
    if (activeColor != null && activeColor != CardColor.wild) {
      if (card.color == activeColor) return true;
    }

    // Check color match (direct)
    if (card.color == topCard.color) return true;

    // Check number or type match
    if (card.type == topCard.type) return true;
    if (card.type == CardType.number && topCard.type == CardType.number) {
      return card.number == topCard.number;
    }

    return false;
  }

  /// Check if a Wild Draw Four is played illegally
  static bool isWildDrawFourChallengeable(
    List<Card> playerHand,
    CardColor? declaredColor,
  ) {
    // If no color was declared, can't challenge
    if (declaredColor == null || declaredColor == CardColor.wild) {
      return false;
    }

    // Check if player has any cards matching the declared color
    final hasCardOfColor = playerHand.any((card) {
      return card.color == declaredColor && card.color != CardColor.wild;
    });

    // If player has a card of the declared color, they played illegally
    return hasCardOfColor;
  }

  /// Get cards that can be played (client-side validation hint)
  static List<Card> getPlayableCards(
    List<Card> hand,
    Card? topCard,
    CardColor? activeColor,
  ) {
    if (topCard == null) return hand;
    return hand
        .where((card) => isValidMove(card, topCard, activeColor))
        .toList();
  }

  /// Calculate round score for all players
  static Map<String, int> calculateRoundScore(
    Map<String, List<Card>> playerHands,
    String winnerId,
  ) {
    final scores = <String, int>{};
    
    for (final entry in playerHands.entries) {
      if (entry.key == winnerId) {
        scores[entry.key] = 0;
      } else {
        int handValue = 0;
        for (final card in entry.value) {
          handValue += card.getPointValue();
        }
        scores[entry.key] = handValue;
      }
    }
    
    return scores;
  }

  /// Get the number of cards a player should draw
  static int getDrawCardsForAction(
    List<Card> lastPlayedCards,
    bool allowStacking,
  ) {
    if (!allowStacking) {
      // Just the card effect
      if (lastPlayedCards.isEmpty) return 0;
      return lastPlayedCards.last.type == CardType.drawTwo ? 2 : 4;
    }

    // Stacking enabled - count all draw cards
    int totalDraw = 0;
    for (final card in lastPlayedCards) {
      if (card.type == CardType.drawTwo) totalDraw += 2;
      if (card.type == CardType.wildDrawFour) totalDraw += 4;
    }
    return totalDraw;
  }

  /// Validate deck consistency
  static bool validateDeckIntegrity(List<Card> deck) {
    // Check total card count (should be 108-112)
    if (deck.length < 108 || deck.length > 112) return false;

    // Check no duplicates
    final ids = deck.map((c) => c.id).toSet();
    if (ids.length != deck.length) return false;

    return true;
  }

  /// Shuffle a deck using Fisher-Yates algorithm
  static List<Card> shuffleDeck(List<Card> deck) {
    final shuffled = List<Card>.from(deck);
    final random = DateTime.now().microsecond; // Poor man's random seed
    
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = (random * (i + 1)).toInt() % (i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    
    return shuffled;
  }

  /// Deal initial hands
  static Map<String, List<Card>> dealInitialHands(
    List<Card> deck,
    List<String> playerIds,
    int cardsPerPlayer,
  ) {
    final hands = <String, List<Card>>{};
    int cardIndex = 0;

    for (final playerId in playerIds) {
      final hand = <Card>[];
      for (int i = 0; i < cardsPerPlayer; i++) {
        if (cardIndex < deck.length) {
          hand.add(deck[cardIndex++]);
        }
      }
      hands[playerId] = hand;
    }

    return hands;
  }

  /// Check if a player should be forced to draw (no valid moves)
  static bool hasValidMove(
    List<Card> hand,
    Card topCard,
    CardColor? activeColor,
  ) {
    return getPlayableCards(hand, topCard, activeColor).isNotEmpty;
  }

  /// Get next player considering skips and reverses
  static int getNextPlayerIndex(
    int currentIndex,
    int totalPlayers,
    bool reverse,
    int skipCount,
  ) {
    if (totalPlayers <= 1) return 0;

    int nextIndex = currentIndex;
    for (int i = 0; i < skipCount + 1; i++) {
      if (reverse) {
        nextIndex = (nextIndex - 1 + totalPlayers) % totalPlayers;
      } else {
        nextIndex = (nextIndex + 1) % totalPlayers;
      }
    }
    return nextIndex;
  }
}

/// Event types for game progress
enum GameEventType {
  cardPlayed,
  cardDrawn,
  playerSkipped,
  directionChanged,
  unoCall,
  challengeIssued,
  challengeResolved,
  roundEnded,
  gameEnded,
}

class GameEvent {
  final GameEventType type;
  final String playerId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  GameEvent({
    required this.type,
    required this.playerId,
    this.data = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'playerId': playerId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
