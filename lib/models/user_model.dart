import '../utils/firestore_value_parser.dart';

enum UserRole { admin, staff, resident }

enum UserStatus { active, inactive }

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.apartmentId,
    required this.nationalId,
    this.dateOfBirth,
    this.avatarUrl,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? apartmentId;
  final String nationalId;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final UserStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == UserStatus.active;

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? apartmentId,
    String? nationalId,
    DateTime? dateOfBirth,
    String? avatarUrl,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      apartmentId: apartmentId ?? this.apartmentId,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      email: FirestoreValueParser.string(json['email']),
      fullName: FirestoreValueParser.string(json['fullName']),
      phone: FirestoreValueParser.string(json['phone']),
      role: UserRole.values.firstWhere(
        (value) => value.name == json['role'],
        orElse: () => UserRole.resident,
      ),
      apartmentId: json['apartmentId'] as String?,
      nationalId: FirestoreValueParser.string(json['nationalId']),
      dateOfBirth: FirestoreValueParser.dateTime(json['dateOfBirth']),
      avatarUrl: json['avatarUrl'] as String?,
      status: UserStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      createdAt: FirestoreValueParser.dateTime(json['createdAt']),
      updatedAt: FirestoreValueParser.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role.name,
      'apartmentId': apartmentId,
      'nationalId': nationalId,
      'dateOfBirth': FirestoreValueParser.timestamp(dateOfBirth),
      'avatarUrl': avatarUrl,
      'status': status.name,
      'createdAt': FirestoreValueParser.timestamp(createdAt),
      'updatedAt': FirestoreValueParser.timestamp(updatedAt),
    };
  }
}
