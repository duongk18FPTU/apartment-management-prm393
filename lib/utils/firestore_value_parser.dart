import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts Firestore values into the types used by the application models.
class FirestoreValueParser {
  const FirestoreValueParser._();

  static DateTime? dateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static Timestamp? timestamp(DateTime? value) {
    return value == null ? null : Timestamp.fromDate(value);
  }

  static String string(Object? value, [String fallback = '']) {
    return value is String ? value : fallback;
  }

  static int integer(Object? value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static double decimal(Object? value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? fallback;
  }

  static List<String> strings(Object? value) {
    if (value is Iterable) {
      return value.whereType<String>().toList(growable: false);
    }
    return const [];
  }
}
