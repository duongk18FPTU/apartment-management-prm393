import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/request_model.dart';
import '../services/base_firestore_service.dart';
import '../services/request_service.dart';

/// State management for maintenance requests (Member 3 — Sprint 1).
class RequestProvider extends ChangeNotifier {
  RequestProvider({RequestRepository? requestService})
    : _service = requestService ?? RequestService();

  final RequestRepository _service;

  List<RequestModel> _requests = [];
  RequestModel? _selected;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  RequestStatus? _statusFilter;

  List<RequestModel> get requests => List.unmodifiable(_requests);
  RequestModel? get selected => _selected;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  RequestStatus? get statusFilter => _statusFilter;

  List<RequestModel> get filteredRequests {
    if (_statusFilter == null) return requests;
    return _requests.where((r) => r.status == _statusFilter).toList();
  }

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadResidentRequests(String residentId) async {
    _setLoading(true);
    _clearError();
    try {
      _requests = await _service.getRequestsByResident(residentId);
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[RequestProvider] loadResidentRequests: $e');
      _errorMessage = 'Không thể tải danh sách yêu cầu';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllRequests({RequestStatus? status}) async {
    _setLoading(true);
    _clearError();
    _statusFilter = status;
    try {
      _requests = await _service.getAllRequests(status: status);
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[RequestProvider] loadAllRequests: $e');
      _errorMessage = 'Không thể tải danh sách yêu cầu';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRequestDetail(String id) async {
    _setLoading(true);
    _clearError();
    try {
      _selected = await _service.getRequest(id);
      if (_selected == null) {
        _errorMessage = 'Không tìm thấy yêu cầu';
      }
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[RequestProvider] loadRequestDetail: $e');
      _errorMessage = 'Không thể tải chi tiết yêu cầu';
    } finally {
      _setLoading(false);
    }
  }

  void setStatusFilter(RequestStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  Future<bool> createRequest({
    required String title,
    required String description,
    required RequestCategory category,
    required String residentId,
    required String apartmentId,
    List<File> imageFiles = const [],
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _service.createRequest(
        title: title,
        description: description,
        category: category,
        residentId: residentId,
        apartmentId: apartmentId,
        imageFiles: imageFiles,
      );
      await loadResidentRequests(residentId);
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('[RequestProvider] createRequest: $e');
      _errorMessage = 'Không thể tạo yêu cầu. Vui lòng thử lại';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateStatus({
    required String requestId,
    required RequestStatus status,
    String? staffId,
    String? resolutionNote,
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _service.updateStatus(
        requestId: requestId,
        status: status,
        staffId: staffId,
        resolutionNote: resolutionNote,
      );
      await loadRequestDetail(requestId);
      // Refresh list in place if present
      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1 && _selected != null) {
        _requests = List.from(_requests)..[index] = _selected!;
      }
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('[RequestProvider] updateStatus: $e');
      _errorMessage = 'Không thể cập nhật trạng thái';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }

  void clearError() => _clearError();

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

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
