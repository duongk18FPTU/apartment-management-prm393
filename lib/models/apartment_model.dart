import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_value_parser.dart';

enum ApartmentStatus { occupied, vacant }

class ApartmentModel {
  const ApartmentModel({
    required this.id,
    required this.number,
    required this.floor,
    required this.building,
    required this.area,
    required this.status,
    this.residentIds = const [],
    this.ownerId,
    this.price,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String number;
  final int floor;
  final String building;
  final double area;
  final String? ownerId;
  final ApartmentStatus status;
  final List<String> residentIds;
  final double? price; // Rent price in millions (VND)
  final String? type; // Room type e.g., '2PN - 2WC'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOccupied => status == ApartmentStatus.occupied;

  /// Helper to get calculated price if not present in Firestore
  double get displayPrice {
    if (price != null) return price!;
    // Calculate a realistic price based on area: e.g., 0.16 million VND per m2
    return double.parse((area * 0.16).toStringAsFixed(1));
  }

  /// Helper to get room type dynamically if not present in Firestore
  String get displayType {
    if (type != null) return type!;
    if (area < 50) return 'Studio';
    if (area < 80) return '2PN - 2WC';
    return '3PN - 2WC';
  }

  /// Factory constructor to parse Firestore document snapshot.
  factory ApartmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ApartmentModel.fromJson(data, id: doc.id);
  }

  /// Factory constructor to parse raw data map.
  factory ApartmentModel.fromMap(Map<String, dynamic> data, String id) {
    return ApartmentModel.fromJson(data, id: id);
  }

  /// Converts this model to a Firestore map for write operations.
  Map<String, dynamic> toMap() {
    return toJson(includeId: false);
  }

  ApartmentModel copyWith({
    String? id,
    String? number,
    int? floor,
    String? building,
    double? area,
    String? ownerId,
    ApartmentStatus? status,
    List<String>? residentIds,
    double? price,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApartmentModel(
      id: id ?? this.id,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      building: building ?? this.building,
      area: area ?? this.area,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      residentIds: residentIds ?? this.residentIds,
      price: price ?? this.price,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ApartmentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final residentIdsList = json['residentIds'] != null
        ? FirestoreValueParser.strings(json['residentIds'])
        : <String>[];
    return ApartmentModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      number: FirestoreValueParser.string(json['number']),
      floor: FirestoreValueParser.integer(json['floor']),
      building: FirestoreValueParser.string(json['building']),
      area: FirestoreValueParser.decimal(json['area']),
      ownerId: json['ownerId'] as String?,
      status: ApartmentStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => residentIdsList.isEmpty
            ? ApartmentStatus.vacant
            : ApartmentStatus.occupied,
      ),
      residentIds: residentIdsList,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      type: json['type'] as String?,
      createdAt: FirestoreValueParser.dateTime(json['createdAt']),
      updatedAt: FirestoreValueParser.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'number': number,
      'floor': floor,
      'building': building,
      'area': area,
      'ownerId': ownerId,
      'status': status.name,
      'residentIds': residentIds,
      if (price != null) 'price': price,
      if (type != null) 'type': type,
      'createdAt': FirestoreValueParser.timestamp(createdAt),
      'updatedAt': FirestoreValueParser.timestamp(updatedAt),
    };
  }
}
