import '../utils/firestore_value_parser.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdBy,
    this.targetRoles = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String type;
  final String createdBy;
  final List<String> targetRoles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return NotificationModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      title: FirestoreValueParser.string(json['title']),
      content: FirestoreValueParser.string(json['content']),
      type: FirestoreValueParser.string(json['type'], 'announcement'),
      createdBy: FirestoreValueParser.string(json['createdBy']),
      targetRoles: FirestoreValueParser.strings(json['targetRoles']),
      createdAt: FirestoreValueParser.dateTime(json['createdAt']),
      updatedAt: FirestoreValueParser.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) => {
        if (includeId) 'id': id,
        'title': title,
        'content': content,
        'type': type,
        'createdBy': createdBy,
        'targetRoles': targetRoles,
        'createdAt': FirestoreValueParser.timestamp(createdAt),
        'updatedAt': FirestoreValueParser.timestamp(updatedAt),
      };
}
