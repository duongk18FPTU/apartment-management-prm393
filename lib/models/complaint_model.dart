import '../utils/firestore_value_parser.dart';

class ComplaintModel {
  const ComplaintModel({
    required this.id,
    required this.content,
    required this.residentId,
    required this.apartmentId,
    required this.status,
    this.response,
    this.respondedBy,
    this.respondedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String content;
  final String residentId;
  final String apartmentId;
  final String status;
  final String? response;
  final String? respondedBy;
  final DateTime? respondedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ComplaintModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ComplaintModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      content: FirestoreValueParser.string(json['content']),
      residentId: FirestoreValueParser.string(json['residentId']),
      apartmentId: FirestoreValueParser.string(json['apartmentId']),
      status: FirestoreValueParser.string(json['status'], 'submitted'),
      response: json['response'] as String?,
      respondedBy: json['respondedBy'] as String?,
      respondedAt: FirestoreValueParser.dateTime(json['respondedAt']),
      createdAt: FirestoreValueParser.dateTime(json['createdAt']),
      updatedAt: FirestoreValueParser.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) => {
        if (includeId) 'id': id,
        'content': content,
        'residentId': residentId,
        'apartmentId': apartmentId,
        'status': status,
        'response': response,
        'respondedBy': respondedBy,
        'respondedAt': FirestoreValueParser.timestamp(respondedAt),
        'createdAt': FirestoreValueParser.timestamp(createdAt),
        'updatedAt': FirestoreValueParser.timestamp(updatedAt),
      };
}
