import '../utils/firestore_value_parser.dart';

class VisitorModel {
  const VisitorModel({
    required this.id,
    required this.visitorName,
    required this.visitorPhone,
    required this.purpose,
    required this.registeredBy,
    required this.apartmentId,
    required this.expectedTime,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.checkedInBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String visitorName;
  final String visitorPhone;
  final String purpose;
  final String registeredBy;
  final String apartmentId;
  final DateTime? expectedTime;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;
  final String? checkedInBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory VisitorModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return VisitorModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      visitorName: FirestoreValueParser.string(json['visitorName']),
      visitorPhone: FirestoreValueParser.string(json['visitorPhone']),
      purpose: FirestoreValueParser.string(json['purpose']),
      registeredBy: FirestoreValueParser.string(json['registeredBy']),
      apartmentId: FirestoreValueParser.string(json['apartmentId']),
      expectedTime: FirestoreValueParser.dateTime(json['expectedTime']),
      checkInTime: FirestoreValueParser.dateTime(json['checkInTime']),
      checkOutTime: FirestoreValueParser.dateTime(json['checkOutTime']),
      status: FirestoreValueParser.string(json['status'], 'registered'),
      checkedInBy: json['checkedInBy'] as String?,
      createdAt: FirestoreValueParser.dateTime(json['createdAt']),
      updatedAt: FirestoreValueParser.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) => {
        if (includeId) 'id': id,
        'visitorName': visitorName,
        'visitorPhone': visitorPhone,
        'purpose': purpose,
        'registeredBy': registeredBy,
        'apartmentId': apartmentId,
        'expectedTime': FirestoreValueParser.timestamp(expectedTime),
        'checkInTime': FirestoreValueParser.timestamp(checkInTime),
        'checkOutTime': FirestoreValueParser.timestamp(checkOutTime),
        'status': status,
        'checkedInBy': checkedInBy,
        'createdAt': FirestoreValueParser.timestamp(createdAt),
        'updatedAt': FirestoreValueParser.timestamp(updatedAt),
      };
}
