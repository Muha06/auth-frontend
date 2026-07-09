import 'package:auth_frontend/features/auth/domain/entities/user.dart';
import 'package:hive_ce/hive.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 0)
class UserProfileHive {
  UserProfileHive({
    required this.id,
    required this.username,
    required this.email,
    required this.hobby,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String hobby;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  factory UserProfileHive.fromJson(Map<String, dynamic> json) {
    return UserProfileHive(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      hobby: json['hobby'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      username: username,
      email: email,
      hobby: hobby,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
