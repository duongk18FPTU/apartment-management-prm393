import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/announcement_service.dart';
import '../services/base_firestore_service.dart';

/// State for building announcements (Member 5 — Announcement module).
class AnnouncementProvider extends ChangeNotifier {
  AnnouncementProvider({AnnouncementRepository? repository})
    : _repository = repository ?? AnnouncementService();

  final AnnouncementRepository _repository;

  List<NotificationModel> _items = [];
  NotificationModel? _selected;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<NotificationModel> get items => List.unmodifiable(_items);
  NotificationModel? get selected => _selected;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadAnnouncements() async {
    _setLoading(true);
    _clearError();
    try {
      final allItems = await _repository.getAnnouncements();
      final supportedTypes = AnnouncementType.values
          .map((type) => type.value)
          .toSet();
      _items = allItems
          .where((item) => supportedTypes.contains(item.type))
          .toList(growable: false);
      if (_items.isEmpty) {
        _items = await _repository.getAnnouncements(type: 'announcement');
      }
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[AnnouncementProvider] loadAnnouncements: $e');
      _errorMessage = 'Không thể tải danh sách thông báo';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDetail(String id) async {
    _setLoading(true);
    _clearError();
    try {
      _selected = await _repository.getByIdAnnouncement(id);
      if (_selected == null) {
        _errorMessage = 'Không tìm thấy thông báo';
      }
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[AnnouncementProvider] loadDetail: $e');
      _errorMessage = 'Không thể tải chi tiết thông báo';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAnnouncement({
    required String title,
    required String content,
    required String createdBy,
    String type = 'announcement',
    List<String> targetRoles = const ['resident', 'staff', 'admin'],
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _repository.createAnnouncement(
        title: title,
        content: content,
        createdBy: createdBy,
        type: type,
        targetRoles: targetRoles,
      );
      await loadAnnouncements();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('[AnnouncementProvider] createAnnouncement: $e');
      _errorMessage = 'Không thể tạo thông báo';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateAnnouncement({
    required String id,
    required String title,
    required String content,
    required String type,
    required List<String> targetRoles,
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _repository.updateAnnouncement(
        id: id,
        title: title,
        content: content,
        type: type,
        targetRoles: targetRoles,
      );
      await loadDetail(id);
      await loadAnnouncements();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật thông báo';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteAnnouncement(String id) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _repository.deleteAnnouncement(id);
      await loadAnnouncements();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Không thể xóa thông báo';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
