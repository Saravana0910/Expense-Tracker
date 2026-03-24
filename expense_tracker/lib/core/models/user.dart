import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? avatarPath;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.createdAt,
    this.avatarPath,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      avatarPath: map['avatarPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'createdAt': createdAt.toUtc(),
      if (avatarPath != null) 'avatarPath': avatarPath,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    DateTime? createdAt,
    String? avatarPath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}