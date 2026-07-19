import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/utils/vietnamese_text.dart';

void main() {
  group('normalizeVietnameseForSearch', () {
    test('removes Vietnamese diacritics and lowercases text', () {
      expect(
        normalizeVietnameseForSearch('  Nguyễn Thị Hồng  '),
        'nguyen thi hong',
      );
    });

    test('normalizes every Vietnamese vowel family', () {
      expect(normalizeVietnameseForSearch('Ắ Ế Ỉ Ỗ Ừ Ỵ Đ'), 'a e i o u y d');
    });

    test('keeps email and apartment identifiers searchable', () {
      expect(
        normalizeVietnameseForSearch('Resident1@Apartment.com'),
        'resident1@apartment.com',
      );
      expect(normalizeVietnameseForSearch('APT-0301'), 'apt-0301');
    });
  });
}
