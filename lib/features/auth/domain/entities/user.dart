import 'package:auth_frontend/features/auth/data/models/user_hive_model.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.hobby,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String username;
  final String email;
  final String hobby;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      hobby: json['hobby'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserProfileHive toHiveModel() {
    return UserProfileHive(
      id: id,
      username: username,
      email: email,
      hobby: hobby,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
