import 'package:equatable/equatable.dart';
import 'package:json_serializable/json_serializable.dart';
import 'card_model.dart';

part 'player_model.g.dart';

@JsonSerializable()
class Player extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final List<Card> hand;
  final int score;
  final bool hasCalledUno;
  final bool isConnected;
  final DateTime lastActivityAt;

  const Player({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.hand,
    this.score = 0,
    this.hasCalledUno = false,
    this.isConnected = true,
    required this.lastActivityAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  /// Create a copy with modified fields
  Player copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    List<Card>? hand,
    int? score,
    bool? hasCalledUno,
    bool? isConnected,
    DateTime? lastActivityAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hand: hand ?? this.hand,
      score: score ?? this.score,
      hasCalledUno: hasCalledUno ?? this.hasCalledUno,
      isConnected: isConnected ?? this.isConnected,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    hand,
    score,
    hasCalledUno,
    isConnected,
    lastActivityAt,
  ];
}

@JsonSerializable()
class PlayerStats extends Equatable {
  final String playerId;
  final int totalGamesPlayed;
  final int totalWins;
  final int totalLosses;
  final int totalScore;
  final double winRate;
  final DateTime updatedAt;

  const PlayerStats({
    required this.playerId,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalScore = 0,
    this.winRate = 0.0,
    required this.updatedAt,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => _$PlayerStatsFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerStatsToJson(this);

  @override
  List<Object?> get props => [
    playerId,
    totalGamesPlayed,
    totalWins,
    totalLosses,
    totalScore,
    winRate,
    updatedAt,
  ];
}
