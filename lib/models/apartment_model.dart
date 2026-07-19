import '../utils/firestore_value_parser.dart';

enum ApartmentStatus { occupied, vacant }

class ApartmentModel {
  const ApartmentModel({
    required this.id,
    required this.number,
    required this.floor,
    required this.building,
    required this.area,
    this.ownerId,
    required this.status,
    this.residentIds = const [],
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isOccupied => status == ApartmentStatus.occupied;

  ApartmentModel copyWith({
    String? id,
    String? number,
    int? floor,
    String? building,
    double? area,
    String? ownerId,
    ApartmentStatus? status,
    List<String>? residentIds,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ApartmentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    final residentIds = FirestoreValueParser.strings(json['residentIds']);
    return ApartmentModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      number: FirestoreValueParser.string(json['number']),
      floor: FirestoreValueParser.integer(json['floor']),
      building: FirestoreValueParser.string(json['building']),
      area: FirestoreValueParser.decimal(json['area']),
      ownerId: json['ownerId'] as String?,
      status: ApartmentStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => residentIds.isEmpty
            ? ApartmentStatus.vacant
            : ApartmentStatus.occupied,
      ),
      residentIds: residentIds,
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
      'createdAt': FirestoreValueParser.timestamp(createdAt),
      'updatedAt': FirestoreValueParser.timestamp(updatedAt),
    };
  }
}
