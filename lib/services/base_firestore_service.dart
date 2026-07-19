import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Abstract base class for Firestore CRUD operations.
///
/// Subclasses (e.g. [RequestService], [ComplaintService]) only need to
/// provide [collectionPath] and call the inherited helpers — they should
/// never talk to [FirebaseFirestore] directly from screens/providers.
///
/// Example:
/// ```dart
/// class RequestService extends BaseFirestoreService {
///   RequestService({super.firestore});
///
///   @override
///   String get collectionPath => AppCollections.requests;
/// }
/// ```
abstract class BaseFirestoreService {
  BaseFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Name of the Firestore collection this service manages.
  String get collectionPath;

  /// Typed reference to the managed collection.
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(collectionPath);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Fetches a single document by [id].
  ///
  /// Returns `null` when the document does not exist.
  Future<DocumentSnapshot<Map<String, dynamic>>> getById(String id) async {
    try {
      return await collection.doc(id).get();
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] getById($id) error: ${e.code}');
      throw FirestoreException(_mapError(e.code));
    }
  }

  /// Fetches all documents in the collection.
  ///
  /// Optionally ordered by [orderBy] ascending when [descending] is false.
  Future<QuerySnapshot<Map<String, dynamic>>> getAll({
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection;
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      return await query.get();
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] getAll error: ${e.code}');
      throw FirestoreException(_mapError(e.code));
    }
  }

  /// Runs a filtered query with a single where-clause.
  Future<QuerySnapshot<Map<String, dynamic>>> where({
    required String field,
    required Object isEqualTo,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection.where(
        field,
        isEqualTo: isEqualTo,
      );
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      return await query.get();
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] where($field) error: ${e.code}');
      throw FirestoreException(_mapError(e.code));
    }
  }

  /// Real-time stream of the entire collection (optionally ordered).
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAll({
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = collection;
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots().handleError((Object error) {
      debugPrint('[$runtimeType] streamAll error: $error');
      if (error is FirebaseException) {
        throw FirestoreException(_mapError(error.code));
      }
      throw FirestoreException(_mapError('unknown'));
    });
  }

  /// Real-time stream filtered by a single where-clause.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamWhere({
    required String field,
    required Object isEqualTo,
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> query = collection.where(
      field,
      isEqualTo: isEqualTo,
    );
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    return query.snapshots().handleError((Object error) {
      debugPrint('[$runtimeType] streamWhere($field) error: $error');
      if (error is FirebaseException) {
        throw FirestoreException(_mapError(error.code));
      }
      throw FirestoreException(_mapError('unknown'));
    });
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Creates a document with an auto-generated ID.
  ///
  /// Automatically stamps `createdAt` and `updatedAt` as server timestamps
  /// when [stampTimestamps] is true (default).
  ///
  /// Returns the new document ID.
  Future<String> create(
    Map<String, dynamic> data, {
    bool stampTimestamps = true,
  }) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      if (stampTimestamps) {
        payload['createdAt'] = FieldValue.serverTimestamp();
        payload['updatedAt'] = FieldValue.serverTimestamp();
      }
      final docRef = await collection.add(payload);
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] create error: ${e.code}');
      throw FirestoreException(_mapError(e.code));
    }
  }

  /// Creates or overwrites a document with a known [id].
  Future<void> set(
    String id,
    Map<String, dynamic> data, {
    bool merge = false,
    bool stampTimestamps = true,
  }) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      if (stampTimestamps) {
        payload.putIfAbsent('createdAt', FieldValue.serverTimestamp);
        payload['updatedAt'] = FieldValue.serverTimestamp();
      }
      await collection.doc(id).set(payload, SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] set($id) error: ${e.code}');
      throw FirestoreException(_mapError(e.code));
    }
  }

  /// Partially updates fields on an existing document.
  ///
  /// Automatically sets `updatedAt` to the server timestamp when
  /// [stampTimestamps] is true (default).
  Future<void> update(
    String id,
    Map<String, dynamic> data, {
    bool stampTimestamps = true,
  }) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      if (stampTimestamps) {
        payload['updatedAt'] = FieldValue.serverTimestamp();
      }
      await collection.doc(id).update(payload);
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] update($id) error: ${e.code}');
      throw FirestoreException(_mapError(e.code));
    }
  }

  /// Deletes a document by [id].
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } on FirebaseException catch (e) {
      debugPrint('[$runtimeType] delete($id) error: ${e.code}');
      throw FirestoreException(_mapError(e.code));
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  /// Maps Firebase/Firestore error codes to user-facing Vietnamese messages.
  static String _mapError(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Bạn không có quyền thực hiện thao tác này';
      case 'not-found':
        return 'Không tìm thấy dữ liệu';
      case 'already-exists':
        return 'Dữ liệu đã tồn tại';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Máy chủ tạm thời không phản hồi. Vui lòng thử lại';
      case 'resource-exhausted':
        return 'Quá nhiều yêu cầu. Vui lòng đợi rồi thử lại';
      case 'unauthenticated':
        return 'Bạn chưa đăng nhập';
      case 'cancelled':
        return 'Thao tác đã bị huỷ';
      case 'invalid-argument':
        return 'Dữ liệu không hợp lệ';
      case 'failed-precondition':
        return 'Không thể thực hiện thao tác ở trạng thái hiện tại';
      default:
        return 'Đã xảy ra lỗi khi truy cập dữ liệu. Vui lòng thử lại';
    }
  }
}

// ---------------------------------------------------------------------------
// FirestoreException
// ---------------------------------------------------------------------------

/// Typed exception thrown by [BaseFirestoreService] with a user-facing message.
class FirestoreException implements Exception {
  const FirestoreException(this.message);

  final String message;

  @override
  String toString() => 'FirestoreException: $message';
}
