import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/complaint_model.dart';

void main() {
  group('ComplaintStatus', () {
    test('maps firestore values', () {
      expect(
        ComplaintStatus.fromString('submitted'),
        ComplaintStatus.submitted,
      );
      expect(ComplaintStatus.fromString('in_review'), ComplaintStatus.inReview);
      expect(ComplaintStatus.fromString('resolved'), ComplaintStatus.resolved);
      expect(ComplaintStatus.fromString('???'), ComplaintStatus.submitted);
    });

    test('labels are Vietnamese', () {
      expect(ComplaintStatus.submitted.label, 'Đã gửi');
      expect(ComplaintStatus.inReview.label, 'Đang xem xét');
      expect(ComplaintStatus.resolved.label, 'Đã phản hồi');
    });
  });

  group('ComplaintModel', () {
    test('fromMap parses response fields', () {
      final model = ComplaintModel.fromMap({
        'content': 'Ồn ào ban đêm',
        'residentId': 'res-1',
        'apartmentId': 'apt-301',
        'status': 'resolved',
        'response': 'Đã nhắc nhở',
        'respondedBy': 'staff-1',
        'respondedAt': null,
        'createdAt': null,
        'updatedAt': null,
      }, 'c-1');

      expect(model.id, 'c-1');
      expect(model.content, 'Ồn ào ban đêm');
      expect(model.status, ComplaintStatus.resolved);
      expect(model.response, 'Đã nhắc nhở');
      expect(model.respondedBy, 'staff-1');

      final map = model.toMap();
      expect(map['status'], 'resolved');
      expect(map['content'], 'Ồn ào ban đêm');
    });
  });
}
