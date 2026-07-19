import 'package:cloud_firestore/cloud_firestore.dart';

/// Maintenance request document from Firestore `requests` collection.
///
/// Schema: CHIA_VIEC.md — Member 3 Sprint 1.
class RequestModel {
  const RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.residentId,
    required this.apartmentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls = const [],
    this.assignedStaffId,
    this.resolutionNote,
  });

  final String id;
  final String title;
  final String description;
  final RequestCategory category;
  final List<String> imageUrls;
  final String residentId;
  final String apartmentId;
  final RequestStatus status;
  final String? assignedStaffId;
  final String? resolutionNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RequestModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return RequestModel.fromMap(data, doc.id);
  }

  factory RequestModel.fromMap(Map<String, dynamic> data, String id) {
    return RequestModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: RequestCategory.fromString(
        data['category'] as String? ?? 'general',
      ),
      imageUrls:
          (data['imageUrls'] as List<dynamic>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const [],
      residentId: data['residentId'] as String? ?? '',
      apartmentId: data['apartmentId'] as String? ?? '',
      status: RequestStatus.fromString(data['status'] as String? ?? 'pending'),
      assignedStaffId: data['assignedStaffId'] as String?,
      resolutionNote: data['resolutionNote'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Payload for create/update — timestamps are stamped by [BaseFirestoreService].
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.firestoreValue,
      'imageUrls': imageUrls,
      'residentId': residentId,
      'apartmentId': apartmentId,
      'status': status.firestoreValue,
      'assignedStaffId': assignedStaffId,
      'resolutionNote': resolutionNote,
    };
  }

  RequestModel copyWith({
    String? title,
    String? description,
    RequestCategory? category,
    List<String>? imageUrls,
    String? residentId,
    String? apartmentId,
    RequestStatus? status,
    String? assignedStaffId,
    String? resolutionNote,
    DateTime? updatedAt,
  }) {
    return RequestModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      residentId: residentId ?? this.residentId,
      apartmentId: apartmentId ?? this.apartmentId,
      status: status ?? this.status,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'RequestModel(id: $id, title: $title, status: ${status.firestoreValue})';
}

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum RequestCategory {
  plumbing,
  electrical,
  general;

  String get firestoreValue => name;

  String get label {
    switch (this) {
      case RequestCategory.plumbing:
        return 'Điện nước / ống nước';
      case RequestCategory.electrical:
        return 'Điện';
      case RequestCategory.general:
        return 'Chung';
    }
  }

  static RequestCategory fromString(String value) {
    return RequestCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => RequestCategory.general,
    );
  }
}

enum RequestStatus {
  pending,
  inProgress,
  completed;

  /// Firestore stores `in_progress` (snake_case).
  String get firestoreValue {
    switch (this) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.inProgress:
        return 'in_progress';
      case RequestStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Chờ xử lý';
      case RequestStatus.inProgress:
        return 'Đang xử lý';
      case RequestStatus.completed:
        return 'Hoàn thành';
    }
  }

  static RequestStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'pending':
      default:
        return RequestStatus.pending;
    }
  }
}
