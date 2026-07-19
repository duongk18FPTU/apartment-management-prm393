import 'package:flutter_test/flutter_test.dart';

import 'package:prm393_project/models/apartment_model.dart';

void main() {
  test('parses and serializes the documented apartment schema', () {
    final apartment = ApartmentModel.fromJson({
      'number': '301',
      'floor': 3,
      'building': 'Building A',
      'area': 65,
      'ownerId': 'resident-001',
      'status': 'occupied',
      'residentIds': ['resident-001'],
    }, id: 'apt-0301');

    expect(apartment.id, 'apt-0301');
    expect(apartment.number, '301');
    expect(apartment.floor, 3);
    expect(apartment.area, 65);
    expect(apartment.status, ApartmentStatus.occupied);
    expect(apartment.toJson()['residentIds'], ['resident-001']);
  });

  test('uses vacant status when a document has no residents and no status', () {
    final apartment = ApartmentModel.fromJson({
      'number': '101',
      'floor': 1,
      'building': 'Building A',
      'area': 65.0,
      'residentIds': <String>[],
    });

    expect(apartment.status, ApartmentStatus.vacant);
    expect(apartment.isOccupied, isFalse);
  });
}
