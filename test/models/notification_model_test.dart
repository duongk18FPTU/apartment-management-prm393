import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson parses announcement fields', () {
      final model = NotificationModel.fromJson({
        'title': 'Bảo trì thang máy',
        'content': 'Tầng 1-5 tạm ngưng',
        'type': 'announcement',
        'createdBy': 'admin-1',
        'targetRoles': ['resident', 'staff'],
      }, id: 'n-1');

      expect(model.id, 'n-1');
      expect(model.title, 'Bảo trì thang máy');
      expect(model.type, 'announcement');
      expect(model.targetRoles, ['resident', 'staff']);

      final json = model.toJson();
      expect(json['title'], 'Bảo trì thang máy');
      expect(json['type'], 'announcement');
    });

    test('defaults type to announcement', () {
      final model = NotificationModel.fromJson({
        'title': 'X',
        'content': 'Y',
        'createdBy': 'admin-1',
      }, id: 'n-2');

      expect(model.type, 'announcement');
    });
  });
}
