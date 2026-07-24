import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/apartment_model.dart';
import '../utils/constants.dart';
import 'base_firestore_service.dart';

abstract class ApartmentRepository {
  Future<ApartmentModel?> getApartment(String id);
  Future<List<ApartmentModel>> getAllApartments();
  Stream<List<ApartmentModel>> watchApartments();
  Future<void> assignResident({
    required String apartmentId,
    required String residentId,
    bool asOwner = false,
  });
  Future<void> unassignResident({
    required String apartmentId,
    required String residentId,
  });
  Future<void> assignOwner({
    required String apartmentId,
    required String? ownerId,
  });
  Future<void> updateApartmentDetails({
    required String apartmentId,
    required double area,
    required String type,
  });
  Future<String> createApartment(ApartmentModel apartment);
  Future<void> updateApartment(ApartmentModel apartment);
  Future<void> deleteApartment(String apartmentId);
}

class ApartmentService extends BaseFirestoreService
    implements ApartmentRepository {
  ApartmentService({super.firestore});

  @override
  String get collectionPath => AppCollections.apartments;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(AppCollections.apartments);

  static Map<String, dynamic> toDocumentData(
    ApartmentModel apartment, {
    DateTime? now,
  }) {
    final map = apartment.toJson();
    map['createdAt'] = FieldValue.serverTimestamp();
    map['updatedAt'] = FieldValue.serverTimestamp();
    return map;
  }

  @override
  Future<ApartmentModel?> getApartment(String id) async {
    final doc = await _collection.doc(id).get();
    final data = doc.data();
    return doc.exists && data != null
        ? ApartmentModel.fromJson(data, id: doc.id)
        : null;
  }

  // Alias for provider
  Future<ApartmentModel?> getApartmentById(String id) => getApartment(id);

  @override
  Future<List<ApartmentModel>> getAllApartments() async {
    final snap = await _collection.orderBy('number').get();
    return snap.docs
        .map((doc) => ApartmentModel.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  // Alias for compatibility
  Future<List<ApartmentModel>> getApartments() => getAllApartments();

  @override
  Stream<List<ApartmentModel>> watchApartments() {
    return _collection
        .orderBy('number')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ApartmentModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<String> createApartment(ApartmentModel apartment) async {
    final doc = apartment.id.isEmpty
        ? _collection.doc()
        : _collection.doc(apartment.id);
    await doc.set(toDocumentData(apartment));
    return doc.id;
  }

  @override
  Future<void> updateApartment(ApartmentModel apartment) {
    final map = apartment.toJson();
    map['updatedAt'] = FieldValue.serverTimestamp();
    return _collection.doc(apartment.id).update(map);
  }

  @override
  Future<void> deleteApartment(String apartmentId) {
    return _collection.doc(apartmentId).delete();
  }

  @override
  Future<void> assignResident({
    required String apartmentId,
    required String residentId,
    bool asOwner = false,
  }) async {
    final apartmentRef = _collection.doc(apartmentId);
    final residentRef = firestore
        .collection(AppCollections.users)
        .doc(residentId);

    await firestore.runTransaction((transaction) async {
      final apartmentSnapshot = await transaction.get(apartmentRef);
      final residentSnapshot = await transaction.get(residentRef);
      if (!apartmentSnapshot.exists || !residentSnapshot.exists) {
        throw StateError('Căn hộ hoặc cư dân không tồn tại.');
      }

      final apartment = ApartmentModel.fromJson(
        apartmentSnapshot.data() ?? <String, dynamic>{},
        id: apartmentId,
      );
      final resident = UserModelAdapter.fromJson(
        residentSnapshot.data() ?? <String, dynamic>{},
        id: residentId,
      );

      if (resident.apartmentId != null && resident.apartmentId != apartmentId) {
        final oldApartmentRef = _collection.doc(resident.apartmentId);
        transaction.update(oldApartmentRef, {
          'residentIds': FieldValue.arrayRemove([residentId]),
          if (residentId == apartment.ownerId) 'ownerId': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final residentIds = {...apartment.residentIds, residentId}.toList();
      transaction.update(apartmentRef, {
        'residentIds': residentIds,
        if (asOwner) 'ownerId': residentId,
        'status': ApartmentStatus.occupied.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(residentRef, {
        'apartmentId': apartmentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> unassignResident({
    required String apartmentId,
    required String residentId,
  }) async {
    final apartmentRef = _collection.doc(apartmentId);
    final residentRef = firestore
        .collection(AppCollections.users)
        .doc(residentId);

    await firestore.runTransaction((transaction) async {
      final apartmentSnapshot = await transaction.get(apartmentRef);
      if (!apartmentSnapshot.exists) {
        throw StateError('Căn hộ không tồn tại.');
      }
      final apartment = ApartmentModel.fromJson(
        apartmentSnapshot.data() ?? <String, dynamic>{},
        id: apartmentId,
      );
      final remainingResidents = apartment.residentIds
          .where((id) => id != residentId)
          .toList();
      transaction.update(apartmentRef, {
        'residentIds': remainingResidents,
        if (apartment.ownerId == residentId) 'ownerId': null,
        'status': remainingResidents.isEmpty
            ? ApartmentStatus.vacant.name
            : ApartmentStatus.occupied.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(residentRef, {
        'apartmentId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> assignOwner({
    required String apartmentId,
    required String? ownerId,
  }) async {
    final aptRef = _collection.doc(apartmentId);
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(aptRef);
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentResidents = List<String>.from(
        data['residentIds'] ?? const [],
      );

      final newStatus = ownerId != null || currentResidents.isNotEmpty
          ? ApartmentStatus.occupied.name
          : ApartmentStatus.vacant.name;

      transaction.update(aptRef, {
        'ownerId': ownerId,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (ownerId != null) {
        final userRef = firestore.collection(AppCollections.users).doc(ownerId);
        transaction.update(userRef, {
          'apartmentId': apartmentId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> updateApartmentDetails({
    required String apartmentId,
    required double area,
    required String type,
  }) async {
    try {
      await _collection.doc(apartmentId).update({
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

class UserModelAdapter {
  const UserModelAdapter({this.apartmentId});

  final String? apartmentId;

  factory UserModelAdapter.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModelAdapter(apartmentId: json['apartmentId'] as String?);
  }
}
