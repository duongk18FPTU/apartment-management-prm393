import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/request_model.dart';
import '../utils/constants.dart';
import 'base_firestore_service.dart';

/// CRUD + image upload for Firestore `requests` collection.
class RequestService extends BaseFirestoreService {
  RequestService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance,
       super(firestore: firestore);

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  @override
  String get collectionPath => AppCollections.requests;

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  Future<RequestModel?> getRequest(String id) async {
    final snap = await getById(id);
    if (!snap.exists || snap.data() == null) return null;
    return RequestModel.fromFirestore(snap);
  }

  Future<List<RequestModel>> getRequestsByResident(String residentId) async {
    // Filter-only query + client sort — avoids composite index requirement.
    final snap = await where(field: 'residentId', isEqualTo: residentId);
    return _sorted(snap.docs.map(RequestModel.fromFirestore));
  }

  Future<List<RequestModel>> getAllRequests({RequestStatus? status}) async {
    final QuerySnapshot<Map<String, dynamic>> snap;
    if (status != null) {
      snap = await where(field: 'status', isEqualTo: status.firestoreValue);
    } else {
      snap = await getAll(orderBy: 'createdAt', descending: true);
      return snap.docs.map(RequestModel.fromFirestore).toList(growable: false);
    }
    return _sorted(snap.docs.map(RequestModel.fromFirestore));
  }

  Stream<List<RequestModel>> streamRequestsByResident(String residentId) {
    return streamWhere(field: 'residentId', isEqualTo: residentId).map(
      (snap) => _sorted(snap.docs.map(RequestModel.fromFirestore)),
    );
  }

  Stream<List<RequestModel>> streamAllRequests({RequestStatus? status}) {
    if (status != null) {
      return streamWhere(
        field: 'status',
        isEqualTo: status.firestoreValue,
      ).map((snap) => _sorted(snap.docs.map(RequestModel.fromFirestore)));
    }
    return streamAll(orderBy: 'createdAt', descending: true).map(
      (snap) => snap.docs.map(RequestModel.fromFirestore).toList(growable: false),
    );
  }

  List<RequestModel> _sorted(Iterable<RequestModel> items) {
    final list = items.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  /// Creates a request and optionally uploads [imageFiles] to Storage.
  Future<String> createRequest({
    required String title,
    required String description,
    required RequestCategory category,
    required String residentId,
    required String apartmentId,
    List<File> imageFiles = const [],
  }) async {
    final imageUrls = <String>[];
    for (final file in imageFiles) {
      imageUrls.add(await uploadRequestImage(residentId: residentId, file: file));
    }

    return create({
      'title': title.trim(),
      'description': description.trim(),
      'category': category.firestoreValue,
      'imageUrls': imageUrls,
      'residentId': residentId,
      'apartmentId': apartmentId,
      'status': RequestStatus.pending.firestoreValue,
      'assignedStaffId': null,
      'resolutionNote': null,
    });
  }

  Future<void> updateStatus({
    required String requestId,
    required RequestStatus status,
    String? staffId,
    String? resolutionNote,
  }) async {
    final data = <String, dynamic>{
      'status': status.firestoreValue,
    };
    if (staffId != null) {
      data['assignedStaffId'] = staffId;
    }
    if (resolutionNote != null) {
      data['resolutionNote'] = resolutionNote.trim();
    }
    await update(requestId, data);
  }

  Future<void> deleteRequest(String requestId) => delete(requestId);

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  /// Uploads a request photo to `request_images/{residentId}/{uuid}.jpg`.
  Future<String> uploadRequestImage({
    required String residentId,
    required File file,
  }) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('request_images/$residentId/$fileName');
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('[RequestService] uploadRequestImage error: ${e.code}');
      throw FirestoreException(
        e.code == 'unauthorized' || e.code == 'permission-denied'
            ? 'Không có quyền tải ảnh lên'
            : 'Không thể tải ảnh lên. Vui lòng thử lại',
      );
    }
  }
}
