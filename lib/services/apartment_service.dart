import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/apartment_model.dart';

class ApartmentService {
  ApartmentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('apartments');

  static Map<String, dynamic> toDocumentData(
    ApartmentModel apartment, {
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();
    return apartment
        .copyWith(
          createdAt: apartment.createdAt ?? timestamp,
          updatedAt: timestamp,
        )
        .toJson();
  }

  Stream<List<ApartmentModel>> watchApartments() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ApartmentModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<List<ApartmentModel>> getApartments() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => ApartmentModel.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  Future<ApartmentModel?> getApartment(String id) async {
    final doc = await _collection.doc(id).get();
    final data = doc.data();
    return doc.exists && data != null
        ? ApartmentModel.fromJson(data, id: doc.id)
        : null;
  }

  Future<String> createApartment(ApartmentModel apartment) async {
    final doc = apartment.id.isEmpty ? _collection.doc() : _collection.doc(apartment.id);
    await doc.set(toDocumentData(apartment));
    return doc.id;
  }

  Future<void> updateApartment(ApartmentModel apartment) {
    return _collection.doc(apartment.id).update(
          apartment.copyWith(updatedAt: DateTime.now()).toJson(),
        );
  }

  Future<void> deleteApartment(String apartmentId) {
    return _collection.doc(apartmentId).delete();
  }

  /// Updates both sides of the apartment-resident relationship atomically.
  Future<void> assignResident({
    required String apartmentId,
    required String residentId,
    bool asOwner = false,
  }) async {
    final apartmentRef = _collection.doc(apartmentId);
    final residentRef = _firestore.collection('users').doc(residentId);

    await _firestore.runTransaction((transaction) async {
      final apartmentSnapshot = await transaction.get(apartmentRef);
      final residentSnapshot = await transaction.get(residentRef);
      if (!apartmentSnapshot.exists || !residentSnapshot.exists) {
        throw StateError('Apartment or resident was not found.');
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
          'updatedAt': Timestamp.now(),
        });
      }

      final residentIds = {...apartment.residentIds, residentId}.toList();
      transaction.update(apartmentRef, {
        'residentIds': residentIds,
        if (asOwner) 'ownerId': residentId,
        'status': 'occupied',
        'updatedAt': Timestamp.now(),
      });
      transaction.update(residentRef, {
        'apartmentId': apartmentId,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  Future<void> unassignResident({
    required String apartmentId,
    required String residentId,
  }) async {
    final apartmentRef = _collection.doc(apartmentId);
    final residentRef = _firestore.collection('users').doc(residentId);

    await _firestore.runTransaction((transaction) async {
      final apartmentSnapshot = await transaction.get(apartmentRef);
      if (!apartmentSnapshot.exists) {
        throw StateError('Apartment was not found.');
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
        'status': remainingResidents.isEmpty ? 'vacant' : 'occupied',
        'updatedAt': Timestamp.now(),
      });
      transaction.update(residentRef, {
        'apartmentId': null,
        'updatedAt': Timestamp.now(),
      });
    });
  }
}

// Kept private to this feature so the service does not create a dependency on
// the full authentication/user-management implementation.
class UserModelAdapter {
  const UserModelAdapter({this.apartmentId});

  final String? apartmentId;

  factory UserModelAdapter.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModelAdapter(apartmentId: json['apartmentId'] as String?);
  }
}
