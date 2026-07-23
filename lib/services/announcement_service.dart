import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import '../utils/constants.dart';
import 'base_firestore_service.dart';

/// Contract for announcement data (Firestore `notifications`).
abstract class AnnouncementRepository {
  Future<NotificationModel?> getByIdAnnouncement(String id);

  Future<List<NotificationModel>> getAnnouncements({String? type});

  Future<String> createAnnouncement({
    required String title,
    required String content,
    required String createdBy,
    String type = 'announcement',
    List<String> targetRoles = const ['resident', 'staff', 'admin'],
  });

  Future<void> updateAnnouncement({
    required String id,
    required String title,
    required String content,
    String? type,
    List<String>? targetRoles,
  });

  Future<void> deleteAnnouncement(String id);
}

/// CRUD for building announcements stored in `notifications`.
class AnnouncementService extends BaseFirestoreService
    implements AnnouncementRepository {
  AnnouncementService({super.firestore});

  @override
  String get collectionPath => AppCollections.notifications;

  NotificationModel _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return NotificationModel.fromJson(doc.data() ?? {}, id: doc.id);
  }

  @override
  Future<NotificationModel?> getByIdAnnouncement(String id) async {
    final snap = await getById(id);
    if (!snap.exists || snap.data() == null) return null;
    return _fromDoc(snap);
  }

  @override
  Future<List<NotificationModel>> getAnnouncements({String? type}) async {
    final QuerySnapshot<Map<String, dynamic>> snap;
    if (type != null) {
      snap = await where(field: 'type', isEqualTo: type);
    } else {
      snap = await getAll(orderBy: 'createdAt', descending: true);
      return snap.docs.map(_fromDoc).toList(growable: false);
    }
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) {
      final aAt = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bAt = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bAt.compareTo(aAt);
    });
    return list;
  }

  @override
  Future<String> createAnnouncement({
    required String title,
    required String content,
    required String createdBy,
    String type = 'announcement',
    List<String> targetRoles = const ['resident', 'staff', 'admin'],
  }) {
    // FCM push for new announcements is deferred (needs Cloud Functions / topic).
    return create({
      'title': title.trim(),
      'content': content.trim(),
      'type': type,
      'createdBy': createdBy,
      'targetRoles': targetRoles,
    });
  }

  @override
  Future<void> updateAnnouncement({
    required String id,
    required String title,
    required String content,
    String? type,
    List<String>? targetRoles,
  }) {
    return update(id, {
      'title': title.trim(),
      'content': content.trim(),
      'type': ?type,
      'targetRoles': ?targetRoles,
    });
  }

  @override
  Future<void> deleteAnnouncement(String id) => delete(id);
}
