import 'package:flutter/foundation.dart';

import '../models/visitor_model.dart';
import '../services/base_firestore_service.dart';
import '../services/visitor_service.dart';

class VisitorProvider extends ChangeNotifier {
  VisitorProvider({VisitorRepository? repository})
    : _repository = repository ?? VisitorService();

  final VisitorRepository _repository;

  List<VisitorModel> _visitors = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<VisitorModel> get visitors => List.unmodifiable(_visitors);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<VisitorModel> get filteredVisitors {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return visitors;
    return _visitors.where((v) {
      return v.visitorName.toLowerCase().contains(q) ||
          v.visitorPhone.contains(q) ||
          v.apartmentId.toLowerCase().contains(q);
    }).toList();
  }

  int get insideCount =>
      _visitors.where((v) => v.status == VisitorStatus.checkedIn).length;

  Future<void> loadAll() async {
    _setLoading(true);
    _clearError();
    try {
      _visitors = await _repository.getAllVisitors();
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('[VisitorProvider] loadAll: $e');
      _errorMessage = 'Không thể tải danh sách khách';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadByResident(String residentId) async {
    _setLoading(true);
    _clearError();
    try {
      _visitors = await _repository.getByResident(residentId);
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách khách';
    } finally {
      _setLoading(false);
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<bool> registerVisitor({
    required String visitorName,
    required String visitorPhone,
    required String purpose,
    required String registeredBy,
    required String apartmentId,
    required DateTime expectedTime,
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _repository.registerVisitor(
        visitorName: visitorName,
        visitorPhone: visitorPhone,
        purpose: purpose,
        registeredBy: registeredBy,
        apartmentId: apartmentId,
        expectedTime: expectedTime,
      );
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Đăng ký khách thất bại';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> checkIn({
    required String visitorId,
    required String staffId,
  }) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _repository.checkIn(visitorId: visitorId, staffId: staffId);
      await loadAll();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Check-in thất bại';
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> checkOut(String visitorId) async {
    _setSubmitting(true);
    _clearError();
    try {
      await _repository.checkOut(visitorId: visitorId);
      await loadAll();
      return true;
    } on FirestoreException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Check-out thất bại';
      return false;
    } finally {
      _setSubmitting(false);
    }
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
