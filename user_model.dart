import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  viewer,
  technical,
  admin,
}

class UserModel {
  final String uid;
  final String username;
  final String email;
  final UserRole role;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      role: _getRoleFromString(data['role'] ?? 'technical'),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'role': role.toString().split('.').last,
      'createdAt': createdAt,
    };
  }

  static UserRole _getRoleFromString(String roleStr) {
    switch (roleStr) {
      case 'admin':
        return UserRole.admin;
      case 'viewer':
        return UserRole.viewer;
      case 'technical':
        return UserRole.technical;
      default:
        return UserRole.technical;
    }
  }

  static String getRoleString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.technical:
        return 'Technical';
      case UserRole.viewer:
        return 'Viewer';
    }
  }
}
