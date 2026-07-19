import 'package:cloud_firestore/cloud_firestore.dart';

enum BillType {
  electricity,
  water,
  service,
  parking;

  String get label {
    return switch (this) {
      BillType.electricity => 'Điện',
      BillType.water => 'Nước',
      BillType.service => 'Phí dịch vụ',
      BillType.parking => 'Phí gửi xe',
    };
  }

  static BillType fromString(String val) {
    return BillType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => BillType.service,
    );
  }
}

class BillModel {
  final String billId;
  final String apartmentId;
  final String residentId;
  final BillType type;
  final double amount;
  final String billingMonth; // Định dạng "YYYY-MM", ví dụ: "2026-07"
  final DateTime dueDate;
  final String status; // 'unpaid' | 'paid' | 'overdue' | 'pending'
  final DateTime? paidAt;
  final String? paymentMethod; // 'cash' | 'bank_transfer'
  final String createdBy; // Staff UID tạo hóa đơn
  final DateTime createdAt;
  final DateTime updatedAt;

  const BillModel({
    required this.billId,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BillModel(
      billId: doc.id,
      apartmentId: data['apartmentId'] as String? ?? '',
      residentId: data['residentId'] as String? ?? '',
      type: BillType.fromString(data['type'] as String? ?? ''),
      amount: (data['amount'] as num? ?? 0.0).toDouble(),
      billingMonth: data['billingMonth'] as String? ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      status: data['status'] as String? ?? 'unpaid',
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      paymentMethod: data['paymentMethod'] as String?,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apartmentId': apartmentId,
      'residentId': residentId,
      'type': type.name,
      'amount': amount,
      'billingMonth': billingMonth,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'paymentMethod': paymentMethod,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BillModel copyWith({
    String? status,
    DateTime? paidAt,
    String? paymentMethod,
    DateTime? updatedAt,
  }) {
    return BillModel(
      billId: billId,
      apartmentId: apartmentId,
      residentId: residentId,
      type: type,
      amount: amount,
      billingMonth: billingMonth,
      dueDate: dueDate,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
