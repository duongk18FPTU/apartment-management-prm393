import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/visitor_model.dart';
import '../utils/constants.dart';
import 'base_firestore_service.dart';

/// Firestore status values: registered | checked_in | checked_out
abstract class VisitorStatus {
  static const registered = 'registered';
  static const checkedIn = 'checked_in';
  static const checkedOut = 'checked_out';

  static String label(String status) {
    switch (status) {
      case checkedIn:
        return 'Trong tòa';
      case checkedOut:
        return 'Đã ra';
      case registered:
      default:
        return 'Chờ check-in';
    }
  }
}

abstract class VisitorRepository {
  Future<List<VisitorModel>> getAllVisitors();

  Future<List<VisitorModel>> getByResident(String residentId);

  Future<VisitorModel?> getVisitor(String id);

  Future<String> registerVisitor({
    required String visitorName,
    required String visitorPhone,
    required String purpose,
    required String registeredBy,
    required String apartmentId,
    required DateTime expectedTime,
  });

  Future<void> checkIn({
    required String visitorId,
    required String staffId,
  });

  Future<void> checkOut({required String visitorId});
}

class VisitorService extends BaseFirestoreService implements VisitorRepository {
  VisitorService({super.firestore});

  @override
  String get collectionPath => AppCollections.visitors;

  VisitorModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return VisitorModel.fromJson(doc.data() ?? {}, id: doc.id);
  }

  List<VisitorModel> _sorted(Iterable<VisitorModel> items) {
    final list = items.toList();
    list.sort((a, b) {
      final aAt = a.expectedTime ?? a.createdAt ?? DateTime(1970);
      final bAt = b.expectedTime ?? b.createdAt ?? DateTime(1970);
      return bAt.compareTo(aAt);
    });
    return list;
  }

  @override
  Future<List<VisitorModel>> getAllVisitors() async {
    final snap = await getAll(orderBy: 'createdAt', descending: true);
    return snap.docs.map(_fromDoc).toList(growable: false);
  }

  @override
  Future<List<VisitorModel>> getByResident(String residentId) async {
    final snap = await where(field: 'registeredBy', isEqualTo: residentId);
    return _sorted(snap.docs.map(_fromDoc));
  }

  @override
  Future<VisitorModel?> getVisitor(String id) async {
    final snap = await getById(id);
    if (!snap.exists || snap.data() == null) return null;
    return _fromDoc(snap);
  }

  @override
  Future<String> registerVisitor({
    required String visitorName,
    required String visitorPhone,
    required String purpose,
    required String registeredBy,
    required String apartmentId,
    required DateTime expectedTime,
  }) {
    return create({
      'visitorName': visitorName.trim(),
      'visitorPhone': visitorPhone.trim(),
      'purpose': purpose.trim(),
      'registeredBy': registeredBy,
      'apartmentId': apartmentId,
      'expectedTime': Timestamp.fromDate(expectedTime),
      'checkInTime': null,
      'checkOutTime': null,
      'status': VisitorStatus.registered,
      'checkedInBy': null,
    });
  }

  @override
  Future<void> checkIn({
    required String visitorId,
    required String staffId,
  }) {
    return update(visitorId, {
      'status': VisitorStatus.checkedIn,
      'checkInTime': FieldValue.serverTimestamp(),
      'checkedInBy': staffId,
    });
  }

  @override
  Future<void> checkOut({required String visitorId}) {
    return update(visitorId, {
      'status': VisitorStatus.checkedOut,
      'checkOutTime': FieldValue.serverTimestamp(),
    });
  }
}
