export enum CardColor {
  Red = 'red',
  Blue = 'blue',
  Green = 'green',
  Yellow = 'yellow',
  Wild = 'wild',
}

export enum CardType {
  Number = 'number',
  Skip = 'skip',
  Reverse = 'reverse',
  DrawTwo = 'drawTwo',
  Wild = 'wild',
  WildDrawFour = 'wildDrawFour',
  CustomBlank = 'customBlank',
}

export interface Card {
  id: string;
  color: CardColor;
  type: CardType;
  number?: number;
  customRule?: string;
}

export interface GamePlayer {
  id: string;
  name: string;
  socketId: string;
  hand: Card[];
  score: number;
  hasCalledUno: boolean;
  isConnected: boolean;
}

export interface GameState {
  id: string;
  roomId: string;
  status: 'waiting' | 'inProgress' | 'finished';
  players: GamePlayer[];
  currentPlayerIndex: number;
  topCard: Card | null;
  direction: 'clockwise' | 'counterClockwise';
  canChallenge: boolean;
  createdAt: Date;
  finishedAt?: Date;
}

export class GameEngine {
  private static readonly STARTING_HAND = 7;

  /**
   * Create a standard UNO deck
   */
  static createDeck(): Card[] {
    const cards: Card[] = [];
    let id = 0;

    const colors = [CardColor.Red, CardColor.Blue, CardColor.Green, CardColor.Yellow];

    // Number cards
    for (const color of colors) {
      // 0 appears once
      cards.push({
        id: `card_${id++}`,
        color,
        type: CardType.Number,
        number: 0,
      });

      // 1-9 appear twice
      for (let number = 1; number <= 9; number++) {
        for (let i = 0; i < 2; i++) {
          cards.push({
            id: `card_${id++}`,
            color,
            type: CardType.Number,
            number,
          });
        }
      }

      // Action cards (2 each)
      for (let i = 0; i < 2; i++) {
        cards.push({
          id: `card_${id++}`,
          color,
          type: CardType.Skip,
        });
        cards.push({
          id: `card_${id++}`,
          color,
          type: CardType.Reverse,
        });
        cards.push({
          id: `card_${id++}`,
          color,
          type: CardType.DrawTwo,
        });
      }
    }

    // Wild cards (4 of each)
    for (let i = 0; i < 4; i++) {
      cards.push({
        id: `card_${id++}`,
        color: CardColor.Wild,
        type: CardType.Wild,
      });
      cards.push({
        id: `card_${id++}`,
        color: CardColor.Wild,
        type: CardType.WildDrawFour,
      });
    }

    // Custom blank cards (4)
    for (let i = 0; i < 4; i++) {
      cards.push({
        id: `card_${id++}`,
        color: CardColor.Wild,
        type: CardType.CustomBlank,
      });
    }

    return cards;
  }

  /**
   * Shuffle deck using Fisher-Yates algorithm
   */
  static shuffleDeck(cards: Card[]): Card[] {
    const deck = [...cards];
    for (let i = deck.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [deck[i], deck[j]] = [deck[j], deck[i]];
    }
    return deck;
  }

  /**
   * Validate if a card can be played
   */
  static isValidMove(
    card: Card,
    topCard: Card | null,
    activeColor: CardColor | null
  ): boolean {
    if (topCard === null) return true;

    // Wild cards can always be played
    if (card.color === CardColor.Wild) {
      return true;
    }

    // Match color with active color (from Wild card)
    if (activeColor && activeColor !== CardColor.Wild && card.color === activeColor) {
      return true;
    }

    // Match color
    if (card.color === topCard.color) {
      return true;
    }

    // Match type or number
    if (card.type === topCard.type) {
      return true;
    }

    if (
      card.type === CardType.Number &&
      topCard.type === CardType.Number &&
      card.number === topCard.number
    ) {
      return true;
    }

    return false;
  }

  /**
   * Get playable cards from hand
   */
  static getPlayableCards(
    hand: Card[],
    topCard: Card | null,
    activeColor: CardColor | null
  ): Card[] {
    return hand.filter((card) =>
      this.isValidMove(card, topCard, activeColor)
    );
  }

  /**
   * Validate Wild Draw Four legality
   */
  static isWildDrawFourLegal(
    playerHand: Card[],
    declaredColor: CardColor | null
  ): boolean {
    if (!declaredColor || declaredColor === CardColor.Wild) {
      return false;
    }

    // Check if player has any cards of the declared color (excluding wild)
    return !playerHand.some(
      (card) => card.color === declaredColor
    );
  }

  /**
   * Calculate score for cards in hand
   */
  static calculateHandScore(cards: Card[]): number {
    return cards.reduce((total, card) => {
      switch (card.type) {
        case CardType.Number:
          return total + (card.number || 0);
        case CardType.Skip:
        case CardType.Reverse:
        case CardType.DrawTwo:
          return total + 20;
        case CardType.Wild:
        case CardType.WildDrawFour:
        case CardType.CustomBlank:
          return total + 50;
        default:
          return total;
      }
    }, 0);
  }

  /**
   * Calculate round scores
   */
  static calculateRoundScores(
    playerHands: Map<string, Card[]>,
    winnerId: string
  ): Map<string, number> {
    const scores = new Map<string, number>();

    for (const [playerId, hand] of playerHands) {
      if (playerId === winnerId) {
        scores.set(playerId, 0);
      } else {
        scores.set(playerId, this.calculateHandScore(hand));
      }
    }

    return scores;
  }

  /**
   * Get next player index
   */
  static getNextPlayerIndex(
    currentIndex: number,
    totalPlayers: number,
    direction: 'clockwise' | 'counterClockwise',
    skipCount: number = 0
  ): number {
    if (totalPlayers <= 1) return 0;

    let nextIndex = currentIndex;
    const steps = skipCount + 1;

    if (direction === 'clockwise') {
      nextIndex = (currentIndex + steps) % totalPlayers;
    } else {
      nextIndex = (currentIndex - steps + totalPlayers * steps) % totalPlayers;
    }

    return nextIndex;
  }

  /**
   * Check if special rule applies for 1v1 (Reverse becomes Skip)
   */
  static isHeadsUpGame(playerCount: number): boolean {
    return playerCount === 2;
  }

  /**
   * Validate deck integrity
   */
  static validateDeck(cards: Card[]): boolean {
    // Check size
    if (cards.length < 108 || cards.length > 112) {
      return false;
    }

    // Check no duplicates
    const ids = new Set(cards.map((c) => c.id));
    return ids.size === cards.length;
  }

  /**
   * Deal initial hands
   */
  static dealInitialHands(
    deck: Card[],
    playerCount: number
  ): Map<string, Card[]> {
    const hands = new Map<string, Card[]>();
    let cardIndex = 0;

    for (let i = 0; i < playerCount; i++) {
      const hand: Card[] = [];
      for (let j = 0; j < this.STARTING_HAND; j++) {
        if (cardIndex < deck.length) {
          hand.push(deck[cardIndex++]);
        }
      }
      hands.set(`player_${i}`, hand);
    }

    return hands;
  }
}
