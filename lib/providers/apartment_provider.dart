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
    ApartmentRepository? apartmentService,
    UserRepository? userService,
  }) : _apartmentService = apartmentService ?? ApartmentService(),
       _userService = userService ?? UserService();

  final ApartmentRepository _apartmentService;
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

  /// Get list after client-side filter and search
  List<ApartmentModel> get filteredApartments {
    final query = normalizeVietnameseForSearch(_searchQuery);
    return _apartments.where((apt) {
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
          matchesFilter = apt.status == 'occupied';
          break;
        case ApartmentFilterType.vacant:
          matchesFilter = apt.status == 'vacant';
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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Loads full details (including resolving Owner and Residents) for a single apartment.
  Future<void> selectApartment(String id) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apt = await _apartmentService.getApartment(id);
      if (apt == null) {
        throw Exception('Không tìm thấy căn hộ');
      }

      _selectedApartment = apt;
      await _resolveSelectedRelations();
      _isLoadingDetail = false;
      notifyListeners();
    } catch (e) {
      _isLoadingDetail = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _resolveSelectedRelations() async {
    if (_selectedApartment == null) return;

    final ownerId = _selectedApartment!.ownerId;
    if (ownerId != null) {
      _selectedOwner = await _userService.getUser(ownerId);
    } else {
      _selectedOwner = null;
    }

    final residents = <UserModel>[];
    for (var rId in _selectedApartment!.residentIds) {
      final user = await _userService.getUser(rId);
      if (user != null) {
        residents.add(user);
      }
    }
    _selectedResidents = residents;
  }

  Future<void> assignResident(String residentId) async {
    if (_selectedApartment == null) return;
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _apartmentService.assignResident(
        _selectedApartment!.id,
        residentId,
      );
      await selectApartment(_selectedApartment!.id); // reload
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> removeResident(String residentId) async {
    if (_selectedApartment == null) return;
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _apartmentService.removeResident(
        _selectedApartment!.id,
        residentId,
      );
      await selectApartment(_selectedApartment!.id); // reload
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> assignOwner(String? ownerId) async {
    if (_selectedApartment == null) return;
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _apartmentService.assignOwner(_selectedApartment!.id, ownerId);
      await selectApartment(_selectedApartment!.id); // reload
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> updateApartmentInfo({
    required double area,
    required String type,
  }) async {
    if (_selectedApartment == null) return;
    _isLoadingDetail = true;
    notifyListeners();

    try {
      await _apartmentService.updateApartmentInfo(
        _selectedApartment!.id,
        area: area,
        type: type,
      );
      await selectApartment(_selectedApartment!.id); // reload
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingDetail = false;
      notifyListeners();
    }
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
