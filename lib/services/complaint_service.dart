import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/complaint_model.dart';
import '../utils/constants.dart';
import 'base_firestore_service.dart';

/// Contract for complaint data access (testable via fakes).
abstract class ComplaintRepository {
  Future<ComplaintModel?> getComplaint(String id);

  Future<List<ComplaintModel>> getComplaintsByResident(String residentId);

  Future<List<ComplaintModel>> getAllComplaints({ComplaintStatus? status});

  Future<String> createComplaint({
    required String content,
    required String residentId,
    required String apartmentId,
  });

  Future<void> respond({
    required String complaintId,
    required String response,
    required String respondedBy,
    ComplaintStatus status = ComplaintStatus.resolved,
  });

  Future<void> markInReview(String complaintId);
}

/// CRUD for Firestore `complaints` collection.
class ComplaintService extends BaseFirestoreService implements ComplaintRepository {
  ComplaintService({super.firestore});

  @override
  String get collectionPath => AppCollections.complaints;

  @override
  Future<ComplaintModel?> getComplaint(String id) async {
    final snap = await getById(id);
    if (!snap.exists || snap.data() == null) return null;
    return ComplaintModel.fromFirestore(snap);
  }

  @override
  Future<List<ComplaintModel>> getComplaintsByResident(String residentId) async {
    final snap = await where(field: 'residentId', isEqualTo: residentId);
    return _sorted(snap.docs.map(ComplaintModel.fromFirestore));
  }

  @override
  Future<List<ComplaintModel>> getAllComplaints({ComplaintStatus? status}) async {
    if (status != null) {
      final snap = await where(
        field: 'status',
        isEqualTo: status.firestoreValue,
      );
      return _sorted(snap.docs.map(ComplaintModel.fromFirestore));
    }
    final snap = await getAll(orderBy: 'createdAt', descending: true);
    return snap.docs.map(ComplaintModel.fromFirestore).toList(growable: false);
  }

  @override
  Future<String> createComplaint({
    required String content,
    required String residentId,
    required String apartmentId,
  }) {
    return create({
      'content': content.trim(),
      'residentId': residentId,
      'apartmentId': apartmentId,
      'status': ComplaintStatus.submitted.firestoreValue,
      'response': null,
      'respondedBy': null,
      'respondedAt': null,
    });
  }

  @override
  Future<void> respond({
    required String complaintId,
    required String response,
    required String respondedBy,
    ComplaintStatus status = ComplaintStatus.resolved,
  }) {
    return update(complaintId, {
      'response': response.trim(),
      'respondedBy': respondedBy,
      'respondedAt': FieldValue.serverTimestamp(),
      'status': status.firestoreValue,
    });
  }

  @override
  Future<void> markInReview(String complaintId) {
    return update(complaintId, {
      'status': ComplaintStatus.inReview.firestoreValue,
    });
  }

  List<ComplaintModel> _sorted(Iterable<ComplaintModel> items) {
    final list = items.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
}
