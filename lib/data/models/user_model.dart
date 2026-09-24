import 'package:equatable/equatable.dart';

enum UserType {
  admin,
  customer,
}

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserType userType;
  final String? token;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.userType = UserType.admin,
    this.token,
    this.avatarUrl,
    this.createdAt,
  });

  bool get isAdmin => userType == UserType.admin;

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    UserType type = UserType.customer;
    final roleRaw = (json['userType'] ?? json['role'] ?? 'admin').toString().toLowerCase();
    if (roleRaw == 'admin' || roleRaw == 'superadmin') {
      type = UserType.admin;
    }

    return UserModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? 'Bhandar Admin',
      phone: json['phone'] ?? json['phoneNumber'] ?? '+91 9876543210',
      email: json['email'] ?? 'admin@krishibhandar.com',
      userType: type,
      token: token ?? json['token'],
      avatarUrl: json['avatarUrl'] ?? json['avatar'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'userType': userType == UserType.admin ? 'admin' : 'customer',
        if (token != null) 'token': token,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserType? userType,
    String? token,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      token: token ?? this.token,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, userType, token, avatarUrl, createdAt];
}
