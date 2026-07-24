import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';
import '../services/visitor_service.dart';

/// Basic admin dashboard counters (Member 5 Sprint 2).
class DashboardStats {
  const DashboardStats({
    required this.apartmentCount,
    required this.residentCount,
    required this.pendingRequests,
    required this.unpaidBills,
    required this.visitorsInside,
  });

  final int apartmentCount;
  final int residentCount;
  final int pendingRequests;
  final int unpaidBills;
  final int visitorsInside;

  static const empty = DashboardStats(
    apartmentCount: 0,
    residentCount: 0,
    pendingRequests: 0,
    unpaidBills: 0,
    visitorsInside: 0,
  );
}

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DashboardStats _stats = DashboardStats.empty;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final apartments = await _db
          .collection(AppCollections.apartments)
          .count()
          .get();
      final residents = await _db
          .collection(AppCollections.users)
          .where('role', isEqualTo: 'resident')
          .count()
          .get();
      final pending = await _db
          .collection(AppCollections.requests)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      final unpaid = await _db
          .collection(AppCollections.bills)
          .where('status', isEqualTo: 'unpaid')
          .count()
          .get();
      final inside = await _db
          .collection(AppCollections.visitors)
          .where('status', isEqualTo: VisitorStatus.checkedIn)
          .count()
          .get();

      _stats = DashboardStats(
        apartmentCount: apartments.count ?? 0,
        residentCount: residents.count ?? 0,
        pendingRequests: pending.count ?? 0,
        unpaidBills: unpaid.count ?? 0,
        visitorsInside: inside.count ?? 0,
      );
    } catch (e) {
      debugPrint('[DashboardProvider] load: $e');
      _errorMessage = 'Không tải được thống kê';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
