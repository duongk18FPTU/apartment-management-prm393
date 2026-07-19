import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';

/// Holds user management data, filters, and mutation states for Admin screens.
class UserProvider extends ChangeNotifier {
  UserProvider({UserRepository? userService})
    : _userService = userService ?? UserService();

  final UserRepository _userService;
  StreamSubscription<List<UserModel>>? _userSubscription;

  List<UserModel> _users = const [];
  List<ApartmentOption> _apartments = const [];
  String _searchQuery = '';
  UserRole? _roleFilter;
  UserStatus? _statusFilter;
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasStartedListening = false;

  List<UserModel> get users => List.unmodifiable(_users);
  List<ApartmentOption> get apartments => List.unmodifiable(_apartments);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  UserRole? get roleFilter => _roleFilter;
  UserStatus? get statusFilter => _statusFilter;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty || _roleFilter != null || _statusFilter != null;

  /// Returns the current list after applying client-side search and filters.
  List<UserModel> get filteredUsers {
    final query = _searchQuery.trim().toLowerCase();
    return _users.where((user) {
      final matchesQuery =
          query.isEmpty ||
          user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.apartmentId?.toLowerCase().contains(query) ?? false);
      return matchesQuery &&
          (_roleFilter == null || user.role == _roleFilter) &&
          (_statusFilter == null || user.status == _statusFilter);
    }).toList();
  }

  void listenToUsers() {
    if (_hasStartedListening) return;
    _hasStartedListening = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _userSubscription = _userService.watchUsers().listen(
      (users) {
        _users = users;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object _) {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách người dùng';
        notifyListeners();
      },
    );
  }

  /// Restarts the Firestore stream after a recoverable loading failure.
  void refreshUsers() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _hasStartedListening = false;
    listenToUsers();
  }

  Future<void> loadApartments() async {
    if (_apartments.isNotEmpty) return;
    try {
      _apartments = await _userService.getApartmentOptions();
      notifyListeners();
    } on UserServiceException catch (exception) {
      _errorMessage = exception.message;
      notifyListeners();
    }
  }

  Future<UserModel?> loadUser(String userId) async {
    for (final user in _users) {
      if (user.uid == userId) return user;
    }
    try {
      return await _userService.getUser(userId);
    } on UserServiceException catch (exception) {
      _errorMessage = exception.message;
      notifyListeners();
      return null;
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setRoleFilter(UserRole? value) {
    _roleFilter = value;
    notifyListeners();
  }

  void setStatusFilter(UserStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _roleFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  Future<bool> createUser({
    required String fullName,
    required String email,
    required String phone,
    required String nationalId,
    required UserRole role,
    String? apartmentId,
  }) async {
    _beginSaving();
    try {
      final result = await _userService.createUser(
        fullName: fullName,
        email: email,
        phone: phone,
        nationalId: nationalId,
        role: role,
        apartmentId: apartmentId,
      );
      _successMessage = result.invitationSent
          ? 'Đã tạo tài khoản và gửi email đặt mật khẩu'
          : 'Đã tạo tài khoản nhưng chưa gửi được email đặt mật khẩu';
      return true;
    } on UserServiceException catch (exception) {
      _errorMessage = exception.message;
      return false;
    } finally {
      _finishSaving();
    }
  }

  Future<bool> updateUser(UserModel user) async {
    _beginSaving();
    try {
      await _userService.updateUser(user);
      _successMessage = 'Đã cập nhật tài khoản người dùng';
      return true;
    } on UserServiceException catch (exception) {
      _errorMessage = exception.message;
      return false;
    } finally {
      _finishSaving();
    }
  }

  Future<bool> updateStatus({
    required String userId,
    required UserStatus status,
    required String currentUserId,
  }) async {
    if (userId == currentUserId && status == UserStatus.inactive) {
      _errorMessage = 'Bạn không thể vô hiệu hóa tài khoản của chính mình';
      notifyListeners();
      return false;
    }

    _beginSaving();
    try {
      await _userService.updateStatus(userId: userId, status: status);
      return true;
    } on UserServiceException catch (exception) {
      _errorMessage = exception.message;
      return false;
    } finally {
      _finishSaving();
    }
  }

  void _beginSaving() {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String? consumeSuccessMessage() {
    final message = _successMessage;
    _successMessage = null;
    return message;
  }

  void _finishSaving() {
    _isSaving = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
