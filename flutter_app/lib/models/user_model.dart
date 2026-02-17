import 'package:equatable/equatable.dart';
import 'package:json_serializable/json_serializable.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isGuestUser;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<String> friendIds;
  final bool hasCompletedProfile;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.isGuestUser = false,
    required this.createdAt,
    this.lastLogin,
    this.friendIds = const [],
    this.hasCompletedProfile = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? isGuestUser,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? friendIds,
    bool? hasCompletedProfile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isGuestUser: isGuestUser ?? this.isGuestUser,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      friendIds: friendIds ?? this.friendIds,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    isGuestUser,
    createdAt,
    lastLogin,
    friendIds,
    hasCompletedProfile,
  ];
}

@JsonSerializable()
class Friend extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final String friendName;
  final String? friendPhotoUrl;
  final bool isOnline;
  final DateTime addedAt;

  const Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    this.friendPhotoUrl,
    this.isOnline = false,
    required this.addedAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
  Map<String, dynamic> toJson() => _$FriendToJson(this);

  @override
  List<Object?> get props => [id, userId, friendId, friendName, friendPhotoUrl, isOnline, addedAt];
}
