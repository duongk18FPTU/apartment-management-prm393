import 'package:flutter/foundation.dart';

import '../models/complaint_model.dart';
import '../services/base_firestore_service.dart';
import '../services/complaint_service.dart';

/// State management for complaints / feedback (Member 3 — Sprint 2).
class ComplaintProvider extends ChangeNotifier {
  ComplaintProvider({ComplaintRepository? complaintService})
    : _service = complaintService ?? ComplaintService();

  final ComplaintRepository _service;

  List<ComplaintModel> _complaints = [];
  ComplaintModel? _selected;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  ComplaintStatus? _statusFilter;

  List<ComplaintModel> get complaints => List.unmodifiable(_complaints);
  ComplaintModel? get selected => _selected;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  ComplaintStatus? get statusFilter => _statusFilter;

  Future<void> loadResidentComplaints(String residentId) async {
    _setLoading(true);
    _clearError();
    try {
      _complaints = await _service.getComplaintsByResident(residentId);
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[ComplaintProvider] loadResidentComplaints: $e');
      _errorMessage = 'Không thể tải danh sách khiếu nại';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllComplaints({ComplaintStatus? status}) async {
    _setLoading(true);
    _clearError();
    _statusFilter = status;
    try {
      _complaints = await _service.getAllComplaints(status: status);
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[ComplaintProvider] loadAllComplaints: $e');
      _errorMessage = 'Không thể tải danh sách khiếu nại';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDetail(String id) async {
    _setLoading(true);
    _clearError();
    try {
      _selected = await _service.getComplaint(id);
      if (_selected == null) {
        _errorMessage = 'Không tìm thấy khiếu nại';
      }
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[ComplaintProvider] loadDetail: $e');
      _errorMessage = 'Không thể tải chi tiết khiếu nại';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createComplaint({
    required String content,
    required String residentId,
    required String apartmentId,
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _service.createComplaint(
        content: content,
        residentId: residentId,
        apartmentId: apartmentId,
      );
      await loadResidentComplaints(residentId);
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('[ComplaintProvider] createComplaint: $e');
      _errorMessage = 'Không thể gửi khiếu nại';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> respond({
    required String complaintId,
    required String response,
    required String respondedBy,
    ComplaintStatus status = ComplaintStatus.resolved,
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _service.respond(
        complaintId: complaintId,
        response: response,
        respondedBy: respondedBy,
        status: status,
      );
      await loadDetail(complaintId);
      final index = _complaints.indexWhere((c) => c.id == complaintId);
      if (index != -1 && _selected != null) {
        _complaints = List.from(_complaints)..[index] = _selected!;
      }
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      debugPrint('[ComplaintProvider] respond: $e');
      _errorMessage = 'Không thể gửi phản hồi';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> markInReview(String complaintId) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _service.markInReview(complaintId);
      await loadDetail(complaintId);
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
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
