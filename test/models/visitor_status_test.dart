import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/visitor_model.dart';
import 'package:prm393_project/providers/dashboard_provider.dart';
import 'package:prm393_project/services/visitor_service.dart';

void main() {
  group('VisitorStatus', () {
    test('labels are Vietnamese', () {
      expect(VisitorStatus.label(VisitorStatus.registered), 'Chờ check-in');
      expect(VisitorStatus.label(VisitorStatus.checkedIn), 'Trong tòa');
      expect(VisitorStatus.label(VisitorStatus.checkedOut), 'Đã ra');
      expect(VisitorStatus.label('unknown'), 'Chờ check-in');
    });
  });

  group('VisitorModel', () {
    test('fromJson parses visitor fields', () {
      final model = VisitorModel.fromJson({
        'visitorName': 'Nguyen Van A',
        'visitorPhone': '0901234567',
        'purpose': 'Thăm người thân',
        'registeredBy': 'res-1',
        'apartmentId': 'A-101',
        'expectedTime': null,
        'status': 'checked_in',
        'checkedInBy': 'staff-1',
      }, id: 'v-1');

      expect(model.id, 'v-1');
      expect(model.visitorName, 'Nguyen Van A');
      expect(model.status, VisitorStatus.checkedIn);
      expect(model.checkedInBy, 'staff-1');

      final json = model.toJson();
      expect(json['status'], 'checked_in');
      expect(json['apartmentId'], 'A-101');
    });
  });

  group('DashboardStats', () {
    test('empty has zero counters', () {
      expect(DashboardStats.empty.apartmentCount, 0);
      expect(DashboardStats.empty.residentCount, 0);
      expect(DashboardStats.empty.pendingRequests, 0);
      expect(DashboardStats.empty.unpaidBills, 0);
      expect(DashboardStats.empty.visitorsInside, 0);
    });

    test('stores provided counters', () {
      const stats = DashboardStats(
        apartmentCount: 10,
        residentCount: 20,
        pendingRequests: 3,
        unpaidBills: 5,
        visitorsInside: 2,
      );

      expect(stats.apartmentCount, 10);
      expect(stats.visitorsInside, 2);
    });
  });
}
