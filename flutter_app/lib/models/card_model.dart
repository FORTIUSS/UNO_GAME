import 'package:equatable/equatable.dart';
import 'package:json_serializable/json_serializable.dart';

part 'card_model.g.dart';

enum CardColor { red, blue, green, yellow, wild }

enum CardType {
  number,      // 0-9
  skip,        // Skip
  reverse,     // Reverse
  drawTwo,     // Draw +2
  wild,        // Wild (choose color)
  wildDrawFour, // Wild +4
  customBlank  // Blank customizable wild cards
}

@JsonSerializable()
class Card extends Equatable {
  final String id;
  final CardColor color;
  final CardType type;
  final int? number; // Only for number cards
  final String? customRule; // For custom blank cards

  const Card({
    required this.id,
    required this.color,
    required this.type,
    this.number,
    this.customRule,
  });

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
  Map<String, dynamic> toJson() => _$CardToJson(this);

  /// Get point value for scoring
  int getPointValue() {
    switch (type) {
      case CardType.number:
        return number ?? 0;
      case CardType.skip:
      case CardType.reverse:
      case CardType.drawTwo:
        return 20;
      case CardType.wild:
      case CardType.wildDrawFour:
        return 50;
      case CardType.customBlank:
        return 50;
    }
  }

  /// Get display name for the card
  String getDisplayName() {
    switch (type) {
      case CardType.number:
        return number.toString();
      case CardType.skip:
        return 'Skip';
      case CardType.reverse:
        return 'Reverse';
      case CardType.drawTwo:
        return '+2';
      case CardType.wild:
        return 'Wild';
      case CardType.wildDrawFour:
        return 'W+4';
      case CardType.customBlank:
        return 'Custom';
    }
  }

  @override
  List<Object?> get props => [id, color, type, number, customRule];
}

class DeckFactory {
  /// Create a standard 112-card UNO deck
  static List<Card> createStandardDeck() {
    final List<Card> cards = [];
    int cardId = 0;

    for (final color in [CardColor.red, CardColor.blue, CardColor.green, CardColor.yellow]) {
      // Number cards 0-9 (0 appears once, 1-9 appear twice each)
      cards.add(Card(
        id: 'card_${cardId++}',
        color: color,
        type: CardType.number,
        number: 0,
      ));

      for (int i = 1; i <= 9; i++) {
        for (int j = 0; j < 2; j++) {
          cards.add(Card(
            id: 'card_${cardId++}',
            color: color,
            type: CardType.number,
            number: i,
          ));
        }
      }

      // Action cards (2 each per color)
      for (int i = 0; i < 2; i++) {
        cards.add(Card(
          id: 'card_${cardId++}',
          color: color,
          type: CardType.skip,
        ));
        cards.add(Card(
          id: 'card_${cardId++}',
          color: color,
          type: CardType.reverse,
        ));
        cards.add(Card(
          id: 'card_${cardId++}',
          color: color,
          type: CardType.drawTwo,
        ));
      }
    }

    // Wild cards (4 of each)
    for (int i = 0; i < 4; i++) {
      cards.add(Card(
        id: 'card_${cardId++}',
        color: CardColor.wild,
        type: CardType.wild,
      ));
      cards.add(Card(
        id: 'card_${cardId++}',
        color: CardColor.wild,
        type: CardType.wildDrawFour,
      ));
    }

    // Custom blank wild cards (4)
    for (int i = 0; i < 4; i++) {
      cards.add(Card(
        id: 'card_${cardId++}',
        color: CardColor.wild,
        type: CardType.customBlank,
      ));
    }

    return cards;
  }
}
