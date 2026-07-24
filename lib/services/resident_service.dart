import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

class ResidentService {
  ResidentService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users');

  static Map<String, dynamic> toDocumentData(UserModel resident) {
    return {
      'email': resident.email,
      'fullName': resident.fullName,
      'phone': resident.phone,
      'role': UserRole.resident.name,
      'apartmentId': resident.apartmentId,
      'nationalId': resident.nationalId,
      'dateOfBirth': resident.dateOfBirth != null
          ? Timestamp.fromDate(resident.dateOfBirth!)
          : null,
      'avatarUrl': resident.avatarUrl,
      'status': resident.status.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Stream<List<UserModel>> watchResidents() {
    return _collection
        .where('role', isEqualTo: 'resident')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<UserModel>> getResidents() async {
    final snapshot = await _collection
        .where('role', isEqualTo: 'resident')
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<UserModel?> getResident(String id) async {
    final doc = await _collection.doc(id).get();
    final data = doc.data();
    return doc.exists && data != null ? UserModel.fromMap(data, doc.id) : null;
  }

  Future<void> createResident(UserModel resident) async {
    await _collection.doc(resident.uid).set(toDocumentData(resident));
  }

  Future<void> updateResident(UserModel resident) async {
    final data = resident.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _collection.doc(resident.uid).update(data);
  }

  Future<void> setResidentStatus(String residentId, UserStatus status) {
    return _collection.doc(residentId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
