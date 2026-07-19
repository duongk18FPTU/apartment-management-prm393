import '../utils/firestore_value_parser.dart';

class BillModel {
  const BillModel({
    required this.id,
    required this.apartmentId,
    required this.residentId,
    required this.type,
    required this.amount,
    required this.billingMonth,
    required this.dueDate,
    required this.status,
    this.paidAt,
    this.paymentMethod,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String apartmentId;
  final String residentId;
  final String type;
  final double amount;
  final String billingMonth;
  final DateTime? dueDate;
  final String status;
  final DateTime? paidAt;
  final String? paymentMethod;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BillModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return BillModel(
      id: id ?? FirestoreValueParser.string(json['id']),
      apartmentId: FirestoreValueParser.string(json['apartmentId']),
      residentId: FirestoreValueParser.string(json['residentId']),
      type: FirestoreValueParser.string(json['type']),
      amount: FirestoreValueParser.decimal(json['amount']),
      billingMonth: FirestoreValueParser.string(json['billingMonth']),
      dueDate: FirestoreValueParser.dateTime(json['dueDate']),
      status: FirestoreValueParser.string(json['status'], 'unpaid'),
      paidAt: FirestoreValueParser.dateTime(json['paidAt']),
      paymentMethod: json['paymentMethod'] as String?,
      createdBy: FirestoreValueParser.string(json['createdBy']),
      createdAt: FirestoreValueParser.dateTime(json['createdAt']),
      updatedAt: FirestoreValueParser.dateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) => {
        if (includeId) 'id': id,
        'apartmentId': apartmentId,
        'residentId': residentId,
        'type': type,
        'amount': amount,
        'billingMonth': billingMonth,
        'dueDate': FirestoreValueParser.timestamp(dueDate),
        'status': status,
        'paidAt': FirestoreValueParser.timestamp(paidAt),
        'paymentMethod': paymentMethod,
        'createdBy': createdBy,
        'createdAt': FirestoreValueParser.timestamp(createdAt),
        'updatedAt': FirestoreValueParser.timestamp(updatedAt),
      };
}
