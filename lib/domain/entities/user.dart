import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? avatar;
  final String? accessToken;
  final String? companyId;
  final String? position;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    this.accessToken,
    this.companyId,
    this.position,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    phone,
    avatar,
    accessToken,
    companyId,
    position,
    phoneNumber,
    createdAt,
    updatedAt,
  ];
} 