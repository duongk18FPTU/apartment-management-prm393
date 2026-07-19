import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/apartment_model.dart';
import '../models/user_model.dart';
import '../services/apartment_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../utils/vietnamese_text.dart';

enum ApartmentFilterType { all, floor1to3, floor4to6, occupied, vacant }

class ApartmentProvider extends ChangeNotifier {
  ApartmentProvider({
    ApartmentService? apartmentService,
    UserRepository? userService,
  }) : _apartmentService = apartmentService ?? ApartmentService(),
       _userService = userService ?? UserService();

  final ApartmentService _apartmentService;
  final UserRepository _userService;

  StreamSubscription<List<ApartmentModel>>? _apartmentSubscription;
  StreamSubscription<List<UserModel>>? _userSubscription;

  List<ApartmentModel> _apartments = const [];
  Map<String, UserModel> _usersMap = const {};
  ApartmentFilterType _filterType = ApartmentFilterType.all;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  // Selected apartment detail states
  ApartmentModel? _selectedApartment;
  UserModel? _selectedOwner;
  List<UserModel> _selectedResidents = const [];
  bool _isLoadingDetail = false;

  // Main branch compat filters
  int? _floor;
  ApartmentStatus? _status;

  List<ApartmentModel> get apartments => _apartments;
  Map<String, UserModel> get usersMap => _usersMap;
  ApartmentFilterType get filterType => _filterType;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ApartmentModel? get selectedApartment => _selectedApartment;
  UserModel? get selectedOwner => _selectedOwner;
  List<UserModel> get selectedResidents => _selectedResidents;
  bool get isLoadingDetail => _isLoadingDetail;

  /// Starts listening to apartments and user profiles to keep names up to date.
  void initialize() {
    _isLoading = true;
    _errorMessage = null;

    // Listen to users map
    _userSubscription?.cancel();
    _userSubscription = _userService.watchUsers().listen(
      (users) {
        _usersMap = {for (var u in users) u.uid: u};
        notifyListeners();
      },
      onError: (err) {
        debugPrint('[ApartmentProvider] User watch error: $err');
      },
    );

    // Listen to apartments
    _apartmentSubscription?.cancel();
    _apartmentSubscription = _apartmentService.watchApartments().listen(
      (apts) {
        _apartments = apts;
        _isLoading = false;
        _errorMessage = null;

        // If the selected apartment is in the list, refresh it
        if (_selectedApartment != null) {
          final updated = apts.cast<ApartmentModel?>().firstWhere(
            (a) => a?.id == _selectedApartment!.id,
            orElse: () => null,
          );
          if (updated != null) {
            _selectedApartment = updated;
            _resolveSelectedRelations();
          }
        }

        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  /// Dummy to support old loadApartments calls
  Future<void> loadApartments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _apartmentService.getApartments();
      _apartments = list;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get list after client-side filter and search
  List<ApartmentModel> get filteredApartments {
    final query = normalizeVietnameseForSearch(_searchQuery);
    return _apartments.where((apt) {
      // Main branch floor filter compatibility
      if (_floor != null && apt.floor != _floor) return false;

      // Main branch status filter compatibility
      if (_status != null && apt.status != _status) return false;

      // Filter Type logic
      bool matchesFilter = true;
      switch (_filterType) {
        case ApartmentFilterType.floor1to3:
          matchesFilter = apt.floor >= 1 && apt.floor <= 3;
          break;
        case ApartmentFilterType.floor4to6:
          matchesFilter = apt.floor >= 4 && apt.floor <= 6;
          break;
        case ApartmentFilterType.occupied:
          matchesFilter = apt.status == ApartmentStatus.occupied;
          break;
        case ApartmentFilterType.vacant:
          matchesFilter = apt.status == ApartmentStatus.vacant;
          break;
        case ApartmentFilterType.all:
          matchesFilter = true;
          break;
      }

      if (!matchesFilter) return false;

      // Search Query logic (by apartment number or owner name)
      if (query.isEmpty) return true;

      final ownerName = apt.ownerId != null
          ? _usersMap[apt.ownerId]?.fullName ?? ''
          : '';
      final normalizedOwnerName = normalizeVietnameseForSearch(ownerName);
      final normalizedNumber = normalizeVietnameseForSearch(apt.number);
      final normalizedBuilding = normalizeVietnameseForSearch(apt.building);

      return normalizedNumber.contains(query) ||
          normalizedOwnerName.contains(query) ||
          normalizedBuilding.contains(query);
    }).toList();
  }

  void setFilterType(ApartmentFilterType type) {
    _filterType = type;
    notifyListeners();
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

  /// Clear all filters
  void clearFilters() {
    _filterType = ApartmentFilterType.all;
    _searchQuery = '';
    _floor = null;
    _status = null;
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _filterType != ApartmentFilterType.all ||
      _searchQuery.isNotEmpty ||
      _floor != null ||
      _status != null;

  /// Loads details for a specific apartment
  Future<void> loadSelectedApartment(String apartmentId) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apt = await _apartmentService.getApartmentById(apartmentId);
      if (apt != null) {
        _selectedApartment = apt;
        _resolveSelectedRelations();
      } else {
        _errorMessage = 'Căn hộ không tồn tại hoặc đã bị xóa';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void _resolveSelectedRelations() {
    if (_selectedApartment == null) return;

    // Resolve owner
    if (_selectedApartment!.ownerId != null) {
      _selectedOwner = _usersMap[_selectedApartment!.ownerId];
    } else {
      _selectedOwner = null;
    }

    // Resolve residents
    _selectedResidents = _selectedApartment!.residentIds
        .map((id) => _usersMap[id])
        .whereType<UserModel>()
        .toList();
  }

  // Selected apartment operations (uses selectedApartment state)
  Future<void> assignResident(String residentId) async {
    if (_selectedApartment == null) return;
    await _apartmentService.assignResident(
      apartmentId: _selectedApartment!.id,
      residentId: residentId,
    );
  }

  Future<void> removeResident(String residentId) async {
    if (_selectedApartment == null) return;
    await _apartmentService.unassignResident(
      apartmentId: _selectedApartment!.id,
      residentId: residentId,
    );
  }

  Future<void> assignOwner(String? ownerId) async {
    if (_selectedApartment == null) return;
    await _apartmentService.assignOwner(
      apartmentId: _selectedApartment!.id,
      ownerId: ownerId,
    );
  }

  Future<void> updateApartmentDetails({required double area, required String type}) async {
    if (_selectedApartment == null) return;
    await _apartmentService.updateApartmentDetails(
      apartmentId: _selectedApartment!.id,
      area: area,
      type: type,
    );
  }

  // compatibility methods for main branch screens
  Future<void> save(ApartmentModel apartment) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (apartment.id.isEmpty) {
        await _apartmentService.createApartment(apartment);
      } else {
        await _apartmentService.updateApartment(apartment);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    await _apartmentService.deleteApartment(id);
  }

  Future<void> assignResidentToApartment({
    required String apartmentId,
    required String residentId,
    bool asOwner = false,
  }) async {
    await _apartmentService.assignResident(
      apartmentId: apartmentId,
      residentId: residentId,
      asOwner: asOwner,
    );
  }

  Future<void> unassignResidentFromApartment({
    required String apartmentId,
    required String residentId,
  }) async {
    await _apartmentService.unassignResident(
      apartmentId: apartmentId,
      residentId: residentId,
    );
  }

  Future<List<UserModel>> getUnassignedResidents() async {
    final users = await _userService.watchUsers().first;
    return users
        .where((u) => u.role == UserRole.resident && u.apartmentId == null)
        .toList();
  }

  void clearSelection() {
    _selectedApartment = null;
    _selectedOwner = null;
    _selectedResidents = const [];
    notifyListeners();
  }

  @override
  void dispose() {
    _apartmentSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
