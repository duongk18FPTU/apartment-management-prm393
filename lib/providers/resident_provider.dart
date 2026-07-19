import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/resident_service.dart';

class ResidentProvider extends ChangeNotifier {
  ResidentProvider({
    ResidentService? service,
    List<UserModel> initialResidents = const [],
  }) : _service = service,
       _residents = initialResidents;

  ResidentService? _service;
  List<UserModel> _residents = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  UserStatus? _status;

  List<UserModel> get residents => List.unmodifiable(_residents);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ResidentService get _dataService => _service ??= ResidentService();

  List<UserModel> get filteredResidents {
    final query = _searchQuery.trim().toLowerCase();
    return _residents.where((resident) {
      final matchesQuery =
          query.isEmpty ||
          resident.fullName.toLowerCase().contains(query) ||
          resident.phone.toLowerCase().contains(query) ||
          (resident.apartmentId ?? '').toLowerCase().contains(query);
      return matchesQuery && (_status == null || resident.status == _status);
    }).toList();
  }

  Future<void> loadResidents() async {
    _isLoading = true;
    notifyListeners();
    try {
      _residents = await _dataService.getResidents();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Unable to load residents. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStatus(UserStatus? value) {
    _status = value;
    notifyListeners();
  }

  Future<void> save(UserModel resident) async {
    if (resident.uid.isEmpty) {
      throw ArgumentError(
        'A resident id is required before creating a profile.',
      );
    }
    await _dataService.updateResident(resident);
    await loadResidents();
  }

  Future<void> create(UserModel resident) async {
    await _dataService.createResident(resident);
    await loadResidents();
  }

  Future<void> toggleStatus(UserModel resident) async {
    await _dataService.setResidentStatus(
      resident.uid,
      resident.isActive ? UserStatus.inactive : UserStatus.active,
    );
    await loadResidents();
  }
}
