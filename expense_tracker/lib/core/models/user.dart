import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
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