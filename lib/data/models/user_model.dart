import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? avatar,
    String? accessToken,
    String? companyId,
    String? position,
    String? phoneNumber,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: role,
          phone: phone,
          avatar: avatar,
          accessToken: accessToken,
          companyId: companyId,
          position: position,
          phoneNumber: phoneNumber,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      print('DEBUG: Parsing UserModel from JSON: $json');
      
    return UserModel(
        id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
        name: json['username']?.toString() ?? json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: json['roleId']?.toString() ?? json['role']?.toString() ?? '',
        phone: json['phone']?.toString(),
        avatar: json['avatar']?.toString(),
        accessToken: json['access_token']?.toString(),
        companyId: json['companyId']?.toString() ?? json['company_id']?.toString(),
        position: json['position']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
    );
    } catch (e) {
      print('DEBUG: Error parsing UserModel: $e');
      print('DEBUG: JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'access_token': accessToken,
      'company_id': companyId,
      'position': position,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
} 