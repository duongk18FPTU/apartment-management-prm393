import '../utils/firestore_value_parser.dart';

class RequestModel {
  const RequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrls = const [],
    required this.residentId,
    required this.apartmentId,
    required this.status,
    this.assignedStaffId,
    this.resolutionNote,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> imageUrls;
  final String residentId;
  final String apartmentId;
  final String status;
  final String? assignedStaffId;
  final String? resolutionNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RequestModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return RequestModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      title: FirestoreValueParser.string(json['title']),
      description: FirestoreValueParser.string(json['description']),
      category: FirestoreValueParser.string(json['category'], 'general'),
      imageUrls: FirestoreValueParser.strings(json['imageUrls']),
      residentId: FirestoreValueParser.string(json['residentId']),
      apartmentId: FirestoreValueParser.string(json['apartmentId']),
      status: FirestoreValueParser.string(json['status'], 'pending'),
      assignedStaffId: json['assignedStaffId'] as String?,
      resolutionNote: json['resolutionNote'] as String?,
      createdAt: FirestoreValueParser.dateTime(json['createdAt']),
      updatedAt: FirestoreValueParser.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) => {
        if (includeId) 'id': id,
        'title': title,
        'description': description,
        'category': category,
        'imageUrls': imageUrls,
        'residentId': residentId,
        'apartmentId': apartmentId,
        'status': status,
        'assignedStaffId': assignedStaffId,
        'resolutionNote': resolutionNote,
        'createdAt': FirestoreValueParser.timestamp(createdAt),
        'updatedAt': FirestoreValueParser.timestamp(updatedAt),
      };
}
