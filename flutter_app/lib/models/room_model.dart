import 'package:equatable/equatable.dart';
import 'package:json_serializable/json_serializable.dart';
import 'game_model.dart';
import 'player_model.dart';

part 'room_model.g.dart';

enum RoomType { public, private }
enum RoomStatus { waiting, active, completed }

@JsonSerializable()
class Room extends Equatable {
  final String id;
  final String name;
  final String hostId;
  final RoomType roomType;
  final RoomStatus status;
  final List<Player> players;
  final int maxPlayers;
  final String? roomCode;  // For private rooms
  final String? inviteLink; // For private rooms
  final HouseRules rules;
  final bool isPasswordProtected;
  final String? password;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int currentRound;
  final ScoringMode scoringMode;
  final Map<String, int> cumulativeScores; // For cumulative scoring mode

  const Room({
    required this.id,
    required this.name,
    required this.hostId,
    this.roomType = RoomType.public,
    this.status = RoomStatus.waiting,
    this.players = const [],
    this.maxPlayers = 4,
    this.roomCode,
    this.inviteLink,
    required this.rules,
    this.isPasswordProtected = false,
    this.password,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
    this.currentRound = 0,
    this.scoringMode = ScoringMode.singleRound,
    this.cumulativeScores = const {},
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  /// Check if room is full
  bool get isFull => players.length >= maxPlayers;

  /// Check if room can start
  bool get canStart => players.length >= 2;

  /// Check if user is host
  bool isHost(String userId) => hostId == userId;

  /// Check if user is in room
  bool hasPlayer(String userId) => players.any((p) => p.id == userId);

  /// Copy with modifications
  Room copyWith({
    String? id,
    String? name,
    String? hostId,
    RoomType? roomType,
    RoomStatus? status,
    List<Player>? players,
    int? maxPlayers,
    String? roomCode,
    String? inviteLink,
    HouseRules? rules,
    bool? isPasswordProtected,
    String? password,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? currentRound,
    ScoringMode? scoringMode,
    Map<String, int>? cumulativeScores,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      roomType: roomType ?? this.roomType,
      status: status ?? this.status,
      players: players ?? this.players,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      roomCode: roomCode ?? this.roomCode,
      inviteLink: inviteLink ?? this.inviteLink,
      rules: rules ?? this.rules,
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      currentRound: currentRound ?? this.currentRound,
      scoringMode: scoringMode ?? this.scoringMode,
      cumulativeScores: cumulativeScores ?? this.cumulativeScores,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    hostId,
    roomType,
    status,
    players,
    maxPlayers,
    roomCode,
    inviteLink,
    rules,
    isPasswordProtected,
    password,
    createdAt,
    startedAt,
    finishedAt,
    currentRound,
    scoringMode,
    cumulativeScores,
  ];
}

@JsonSerializable()
class RoomInvite extends Equatable {
  final String id;
  final String roomId;
  final String invitedById;
  final String invitedUserId;
  final DateTime sentAt;
  final DateTime? acceptedAt;
  final bool isAccepted;

  const RoomInvite({
    required this.id,
    required this.roomId,
    required this.invitedById,
    required this.invitedUserId,
    required this.sentAt,
    this.acceptedAt,
    this.isAccepted = false,
  });

  factory RoomInvite.fromJson(Map<String, dynamic> json) => _$RoomInviteFromJson(json);
  Map<String, dynamic> toJson() => _$RoomInviteToJson(this);

  @override
  List<Object?> get props => [id, roomId, invitedById, invitedUserId, sentAt, acceptedAt, isAccepted];
}
