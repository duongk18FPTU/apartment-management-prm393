import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an apartment document from Firestore `apartments` collection.
class ApartmentModel {
  const ApartmentModel({
    required this.id,
    required this.number,
    required this.floor,
    required this.building,
    required this.area,
    required this.status,
    required this.residentIds,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId,
    this.price,
    this.type,
  });

  final String id;
  final String number;
  final int floor;
  final String building;
  final double area;
  final String? ownerId;
  final String status; // 'occupied' | 'vacant'
  final List<String> residentIds;
  final double? price; // Rent price in millions (VND)
  final String? type; // Room type e.g., '2PN - 2WC'
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOccupied => status == 'occupied';

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
    return ApartmentModel.fromMap(data, doc.id);
  }

  /// Factory constructor to parse raw data map.
  factory ApartmentModel.fromMap(Map<String, dynamic> data, String id) {
    return ApartmentModel(
      id: id,
      number: data['number'] as String? ?? '',
      floor: (data['floor'] as num?)?.toInt() ?? 1,
      building: data['building'] as String? ?? 'Horizon Tower',
      area: (data['area'] as num?)?.toDouble() ?? 0.0,
      ownerId: data['ownerId'] as String?,
      status: data['status'] as String? ?? 'vacant',
      residentIds: List<String>.from(data['residentIds'] ?? const []),
      price: (data['price'] as num?)?.toDouble(),
      type: data['type'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore map for write operations.
  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'floor': floor,
      'building': building,
      'area': area,
      'ownerId': ownerId,
      'status': status,
      'residentIds': residentIds,
      if (price != null) 'price': price,
      if (type != null) 'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ApartmentModel copyWith({
    String? number,
    int? floor,
    String? building,
    double? area,
    String? ownerId,
    String? status,
    List<String>? residentIds,
    double? price,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApartmentModel(
      id: id,
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
}
