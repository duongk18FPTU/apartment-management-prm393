import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/services/base_firestore_service.dart';

void main() {
  group('FirestoreException', () {
    test('toString includes message', () {
      const error = FirestoreException('Không tìm thấy dữ liệu');
      expect(error.message, 'Không tìm thấy dữ liệu');
      expect(error.toString(), contains('Không tìm thấy dữ liệu'));
    });
  });
}
