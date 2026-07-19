import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/request_model.dart';

void main() {
  group('RequestStatus', () {
    test('maps firestore snake_case values', () {
      expect(RequestStatus.fromString('pending'), RequestStatus.pending);
      expect(RequestStatus.fromString('in_progress'), RequestStatus.inProgress);
      expect(RequestStatus.fromString('completed'), RequestStatus.completed);
      expect(RequestStatus.fromString('unknown'), RequestStatus.pending);
    });

    test('exposes firestore values and Vietnamese labels', () {
      expect(RequestStatus.inProgress.firestoreValue, 'in_progress');
      expect(RequestStatus.pending.label, 'Chờ xử lý');
      expect(RequestStatus.completed.label, 'Hoàn thành');
    });
  });

  group('RequestCategory', () {
    test('parses known categories with general fallback', () {
      expect(RequestCategory.fromString('plumbing'), RequestCategory.plumbing);
      expect(
        RequestCategory.fromString('electrical'),
        RequestCategory.electrical,
      );
      expect(RequestCategory.fromString('xyz'), RequestCategory.general);
    });
  });

  group('RequestModel', () {
    test('fromMap / toMap round-trip keeps core fields', () {
      final now = DateTime(2026, 7, 19, 10);
      final map = {
        'title': 'Vòi nước rò',
        'description': 'Phòng 301',
        'category': 'plumbing',
        'imageUrls': ['https://example.com/a.jpg'],
        'residentId': 'res-1',
        'apartmentId': 'apt-301',
        'status': 'in_progress',
        'assignedStaffId': 'staff-1',
        'resolutionNote': null,
        'createdAt': null,
        'updatedAt': null,
      };

      // without Timestamp — createdAt/updatedAt fallback to DateTime.now
      final model = RequestModel.fromMap(map, 'req-1');
      expect(model.id, 'req-1');
      expect(model.title, 'Vòi nước rò');
      expect(model.category, RequestCategory.plumbing);
      expect(model.status, RequestStatus.inProgress);
      expect(model.imageUrls, ['https://example.com/a.jpg']);
      expect(model.assignedStaffId, 'staff-1');

      final out = model.toMap();
      expect(out['title'], 'Vòi nước rò');
      expect(out['category'], 'plumbing');
      expect(out['status'], 'in_progress');
      expect(out['residentId'], 'res-1');

      final copy = model.copyWith(
        status: RequestStatus.completed,
        resolutionNote: 'Đã thay gasket',
        updatedAt: now,
      );
      expect(copy.status, RequestStatus.completed);
      expect(copy.resolutionNote, 'Đã thay gasket');
      expect(copy.title, model.title);
    });
  });
}
