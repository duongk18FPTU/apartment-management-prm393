import 'package:flutter_test/flutter_test.dart';

import 'package:prm393_project/models/apartment_model.dart';
import 'package:prm393_project/services/apartment_service.dart';

void main() {
  test('builds a Firestore document with apartment fields and timestamps', () {
    final now = DateTime(2026, 7, 19);
    final data = ApartmentService.toDocumentData(
      const ApartmentModel(
        id: 'apt-0301',
        number: '301',
        floor: 3,
        building: 'Building A',
        area: 65,
        status: ApartmentStatus.vacant,
      ),
      now: now,
    );

    expect(data['number'], '301');
    expect(data['floor'], 3);
    expect(data['building'], 'Building A');
    expect(data['status'], 'vacant');
    expect(data['residentIds'], isEmpty);
    expect(data['createdAt'], isNotNull);
    expect(data['updatedAt'], isNotNull);
  });
}
