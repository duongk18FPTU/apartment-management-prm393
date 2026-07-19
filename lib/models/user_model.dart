import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

/// Represents a user document from Firestore `users` collection.
///
/// Implements the full schema defined in CHIA_VIEC.md.
/// This class replaces the temporary `UserProfile` from Sprint 0.
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.nationalId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.apartmentId,
    this.dateOfBirth,
    this.avatarUrl,
  });

  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? apartmentId;
  final String nationalId;
  final DateTime? dateOfBirth;
  final String? avatarUrl;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // Firestore serialisation
  // ---------------------------------------------------------------------------

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String? ?? ''),
      apartmentId: data['apartmentId'] as String?,
      nationalId: data['nationalId'] as String? ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      status: UserStatus.fromString(data['status'] as String? ?? 'active'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates a [UserModel] from a raw Firestore data map + document ID.
  ///
  /// Useful when reading from query snapshots or [AuthProvider].
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String? ?? ''),
      apartmentId: data['apartmentId'] as String?,
      nationalId: data['nationalId'] as String? ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      avatarUrl: data['avatarUrl'] as String?,
      status: UserStatus.fromString(data['status'] as String? ?? 'active'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore-compatible map for write operations.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role.name,
      'apartmentId': apartmentId,
      'nationalId': nationalId,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'avatarUrl': avatarUrl,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  UserModel copyWith({
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? apartmentId,
    bool clearApartmentId = false,
    String? nationalId,
    DateTime? dateOfBirth,
    String? avatarUrl,
    UserStatus? status,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      apartmentId: clearApartmentId ? null : apartmentId ?? this.apartmentId,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Display-friendly name: first name only, or full email prefix as fallback.
  String get displayName {
    if (fullName.isNotEmpty) return fullName.split(' ').first;
    return email.split('@').first;
  }

  bool get isActive => status == UserStatus.active;

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, role: ${role.name})';
}

// ---------------------------------------------------------------------------
// UserStatus enum
// ---------------------------------------------------------------------------

/// Account status for a user.
enum UserStatus {
  active,
  inactive;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => UserStatus.active,
    );
  }
}
