import 'package:flutter/foundation.dart';

import '../models/apartment_model.dart';
import '../services/apartment_service.dart';

class ApartmentProvider extends ChangeNotifier {
  ApartmentProvider({
    ApartmentService? service,
    List<ApartmentModel> initialApartments = const [],
  })  : _service = service,
        _apartments = initialApartments;

  ApartmentService? _service;
  List<ApartmentModel> _apartments = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int? _floor;
  ApartmentStatus? _status;

  List<ApartmentModel> get apartments => List.unmodifiable(_apartments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ApartmentService get _dataService => _service ??= ApartmentService();

  List<ApartmentModel> get filteredApartments {
    final query = _searchQuery.trim().toLowerCase();
    return _apartments.where((apartment) {
      final matchesQuery = query.isEmpty ||
          apartment.number.toLowerCase().contains(query) ||
          apartment.building.toLowerCase().contains(query);
      return matchesQuery &&
          (_floor == null || apartment.floor == _floor) &&
          (_status == null || apartment.status == _status);
    }).toList();
  }

  Future<void> loadApartments() async {
    _setLoading(true);
    try {
      _apartments = await _dataService.getApartments();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Unable to load apartments. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setFloor(int? value) {
    _floor = value;
    notifyListeners();
  }

  void setStatus(ApartmentStatus? value) {
    _status = value;
    notifyListeners();
  }

  Future<void> save(ApartmentModel apartment) async {
    _setLoading(true);
    try {
      if (apartment.id.isEmpty) {
        await _dataService.createApartment(apartment);
      } else {
        await _dataService.updateApartment(apartment);
      }
      await loadApartments();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> delete(String id) async {
    await _dataService.deleteApartment(id);
    await loadApartments();
  }

  Future<void> assignResident({
    required String apartmentId,
    required String residentId,
    bool asOwner = false,
  }) async {
    await _dataService.assignResident(
      apartmentId: apartmentId,
      residentId: residentId,
      asOwner: asOwner,
    );
    await loadApartments();
  }

  Future<void> unassignResident({
    required String apartmentId,
    required String residentId,
  }) async {
    await _dataService.unassignResident(
      apartmentId: apartmentId,
      residentId: residentId,
    );
    await loadApartments();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
