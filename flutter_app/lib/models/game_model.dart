import 'package:equatable/equatable.dart';
import 'package:json_serializable/json_serializable.dart';
import 'card_model.dart';
import 'player_model.dart';

part 'game_model.g.dart';

enum GameStatus { waiting, inProgress, finished }
enum GameDirection { clockwise, counterClockwise }
enum ScoringMode { singleRound, cumulative }

@JsonSerializable()
class HouseRules extends Equatable {
  final bool allowStacking;      // +2 on +2, +4 on +4
  final bool allowJumpIn;        // Play identical cards instantly
  final bool allowForcePlay;     // Play cards directly from hand
  final bool allowCustomRules;   // Allow custom blank card rules
  final int maxPlayers;
  final int startingHandSize;

  const HouseRules({
    this.allowStacking = false,
    this.allowJumpIn = false,
    this.allowForcePlay = false,
    this.allowCustomRules = true,
    this.maxPlayers = 10,
    this.startingHandSize = 7,
  });

  factory HouseRules.fromJson(Map<String, dynamic> json) => _$HouseRulesFromJson(json);
  Map<String, dynamic> toJson() => _$HouseRulesToJson(this);

  @override
  List<Object?> get props => [
    allowStacking,
    allowJumpIn,
    allowForcePlay,
    allowCustomRules,
    maxPlayers,
    startingHandSize,
  ];
}

@JsonSerializable()
class GameState extends Equatable {
  final String roomId;
  final String gameId;
  final GameStatus status;
  final List<Player> players;
  final int currentPlayerIndex;
  final Card? topDiscardCard;
  final List<Card> discardPile;
  final GameDirection direction;
  final bool canChallenge;
  final int consecutiveDrawTwoCards;
  final ScoringMode scoringMode;
  final HouseRules rules;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final String? winnerId;

  const GameState({
    required this.roomId,
    required this.gameId,
    this.status = GameStatus.waiting,
    this.players = const [],
    this.currentPlayerIndex = 0,
    this.topDiscardCard,
    this.discardPile = const [],
    this.direction = GameDirection.clockwise,
    this.canChallenge = false,
    this.consecutiveDrawTwoCards = 0,
    this.scoringMode = ScoringMode.singleRound,
    required this.rules,
    required this.createdAt,
    this.finishedAt,
    this.winnerId,
  });

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  /// Get current player
  Player? get currentPlayer {
    if (players.isEmpty || currentPlayerIndex >= players.length) return null;
    return players[currentPlayerIndex];
  }

  /// Get next player index
  int getNextPlayerIndex() {
    int nextIndex = currentPlayerIndex;
    if (direction == GameDirection.clockwise) {
      nextIndex = (currentPlayerIndex + 1) % players.length;
    } else {
      nextIndex = (currentPlayerIndex - 1 + players.length) % players.length;
    }
    return nextIndex;
  }

  /// Copy with modifications
  GameState copyWith({
    String? roomId,
    String? gameId,
    GameStatus? status,
    List<Player>? players,
    int? currentPlayerIndex,
    Card? topDiscardCard,
    List<Card>? discardPile,
    GameDirection? direction,
    bool? canChallenge,
    int? consecutiveDrawTwoCards,
    ScoringMode? scoringMode,
    HouseRules? rules,
    DateTime? createdAt,
    DateTime? finishedAt,
    String? winnerId,
  }) {
    return GameState(
      roomId: roomId ?? this.roomId,
      gameId: gameId ?? this.gameId,
      status: status ?? this.status,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      topDiscardCard: topDiscardCard ?? this.topDiscardCard,
      discardPile: discardPile ?? this.discardPile,
      direction: direction ?? this.direction,
      canChallenge: canChallenge ?? this.canChallenge,
      consecutiveDrawTwoCards: consecutiveDrawTwoCards ?? this.consecutiveDrawTwoCards,
      scoringMode: scoringMode ?? this.scoringMode,
      rules: rules ?? this.rules,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  @override
  List<Object?> get props => [
    roomId,
    gameId,
    status,
    players,
    currentPlayerIndex,
    topDiscardCard,
    discardPile,
    direction,
    canChallenge,
    consecutiveDrawTwoCards,
    scoringMode,
    rules,
    createdAt,
    finishedAt,
    winnerId,
  ];
}

@JsonSerializable()
class RoundResult extends Equatable {
  final String roundId;
  final String winnerId;
  final int winnerScore;
  final Map<String, int> playerScores;
  final DateTime finishedAt;

  const RoundResult({
    required this.roundId,
    required this.winnerId,
    required this.winnerScore,
    required this.playerScores,
    required this.finishedAt,
  });

  factory RoundResult.fromJson(Map<String, dynamic> json) => _$RoundResultFromJson(json);
  Map<String, dynamic> toJson() => _$RoundResultToJson(this);

  @override
  List<Object?> get props => [roundId, winnerId, winnerScore, playerScores, finishedAt];
}
