import 'package:cloud_firestore/cloud_firestore.dart';

/// Complaint / feedback document from Firestore `complaints` collection.
///
/// Schema: CHIA_VIEC.md — Member 3 Sprint 2.
class ComplaintModel {
  const ComplaintModel({
    required this.id,
    required this.content,
    required this.residentId,
    required this.apartmentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.response,
    this.respondedBy,
    this.respondedAt,
  });

  final String id;
  final String content;
  final String residentId;
  final String apartmentId;
  final ComplaintStatus status;
  final String? response;
  final String? respondedBy;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ComplaintModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return ComplaintModel.fromMap(doc.data()!, doc.id);
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> data, String id) {
    return ComplaintModel(
      id: id,
      content: data['content'] as String? ?? '',
      residentId: data['residentId'] as String? ?? '',
      apartmentId: data['apartmentId'] as String? ?? '',
      status: ComplaintStatus.fromString(
        data['status'] as String? ?? 'submitted',
      ),
      response: data['response'] as String?,
      respondedBy: data['respondedBy'] as String?,
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'residentId': residentId,
      'apartmentId': apartmentId,
      'status': status.firestoreValue,
      'response': response,
      'respondedBy': respondedBy,
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
    };
  }

  ComplaintModel copyWith({
    String? content,
    ComplaintStatus? status,
    String? response,
    String? respondedBy,
    DateTime? respondedAt,
    DateTime? updatedAt,
  }) {
    return ComplaintModel(
      id: id,
      content: content ?? this.content,
      residentId: residentId,
      apartmentId: apartmentId,
      status: status ?? this.status,
      response: response ?? this.response,
      respondedBy: respondedBy ?? this.respondedBy,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

enum ComplaintStatus {
  submitted,
  inReview,
  resolved;

  String get firestoreValue {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'submitted';
      case ComplaintStatus.inReview:
        return 'in_review';
      case ComplaintStatus.resolved:
        return 'resolved';
    }
  }

  String get label {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'Đã gửi';
      case ComplaintStatus.inReview:
        return 'Đang xem xét';
      case ComplaintStatus.resolved:
        return 'Đã phản hồi';
    }
  }

  static ComplaintStatus fromString(String value) {
    switch (value) {
      case 'in_review':
        return ComplaintStatus.inReview;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'submitted':
      default:
        return ComplaintStatus.submitted;
    }
  }
}
