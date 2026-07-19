import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/apartment_model.dart';
import '../utils/constants.dart';
import 'base_firestore_service.dart';

abstract class ApartmentRepository {
  Future<ApartmentModel?> getApartment(String id);
  Future<List<ApartmentModel>> getAllApartments();
  Stream<List<ApartmentModel>> watchApartments();
  Future<void> assignResident(String apartmentId, String residentId);
  Future<void> removeResident(String apartmentId, String residentId);
  Future<void> assignOwner(String apartmentId, String? ownerId);
  Future<void> updateApartmentInfo(
    String apartmentId, {
    required double area,
    required String type,
  });
}

class ApartmentService extends BaseFirestoreService
    implements ApartmentRepository {
  ApartmentService({super.firestore});

  @override
  String get collectionPath => AppCollections.apartments;

  @override
  Future<ApartmentModel?> getApartment(String id) async {
    final snap = await getById(id);
    if (!snap.exists || snap.data() == null) return null;
    return ApartmentModel.fromFirestore(snap);
  }

  @override
  Future<List<ApartmentModel>> getAllApartments() async {
    final snap = await getAll(orderBy: 'number');
    return snap.docs.map(ApartmentModel.fromFirestore).toList();
  }

  @override
  Stream<List<ApartmentModel>> watchApartments() {
    return collection
        .orderBy('number')
        .snapshots()
        .map((snap) => snap.docs.map(ApartmentModel.fromFirestore).toList());
  }

  @override
  Future<void> assignResident(String apartmentId, String residentId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Update Apartment
      final aptRef = collection.doc(apartmentId);
      batch.update(aptRef, {
        'residentIds': FieldValue.arrayUnion([residentId]),
        'status': 'occupied',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update User Profile
      final userRef = FirebaseFirestore.instance
          .collection(AppCollections.users)
          .doc(residentId);
      batch.update(userRef, {
        'apartmentId': apartmentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirestoreException('Không thể gán cư dân: ${e.message}');
    }
  }

  @override
  Future<void> removeResident(String apartmentId, String residentId) async {
    try {
      final aptRef = collection.doc(apartmentId);
      final doc = await aptRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentResidents = List<String>.from(
        data['residentIds'] ?? const [],
      );
      final ownerId = data['ownerId'] as String?;

      currentResidents.remove(residentId);
      final newStatus = ownerId != null || currentResidents.isNotEmpty
          ? 'occupied'
          : 'vacant';

      final batch = FirebaseFirestore.instance.batch();

      // Update Apartment
      batch.update(aptRef, {
        'residentIds': currentResidents,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update User Profile
      final userRef = FirebaseFirestore.instance
          .collection(AppCollections.users)
          .doc(residentId);
      batch.update(userRef, {
        'apartmentId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirestoreException('Không thể xóa cư dân: ${e.message}');
    }
  }

  @override
  Future<void> assignOwner(String apartmentId, String? ownerId) async {
    try {
      final aptRef = collection.doc(apartmentId);
      final doc = await aptRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentResidents = List<String>.from(
        data['residentIds'] ?? const [],
      );
      final newStatus = ownerId != null || currentResidents.isNotEmpty
          ? 'occupied'
          : 'vacant';

      final batch = FirebaseFirestore.instance.batch();

      // Update Apartment
      batch.update(aptRef, {
        'ownerId': ownerId,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update new owner User Profile
      if (ownerId != null) {
        final userRef = FirebaseFirestore.instance
            .collection(AppCollections.users)
            .doc(ownerId);
        batch.update(userRef, {
          'apartmentId': apartmentId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirestoreException('Không thể gán chủ hộ: ${e.message}');
    }
  }

  @override
  Future<void> updateApartmentInfo(
    String apartmentId, {
    required double area,
    required String type,
  }) async {
    try {
      await collection.doc(apartmentId).update({
        'area': area,
        'type': type,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        'Không thể cập nhật thông tin căn hộ: ${e.message}',
      );
    }
  }
}
