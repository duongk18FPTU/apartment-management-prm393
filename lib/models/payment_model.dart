import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String paymentId;
  final String billId;
  final String apartmentId;
  final String residentId;
  final double amount;
  final String paymentMethod; // 'cash' | 'bank_transfer'
  final String status; // 'pending' | 'approved' | 'rejected'
  final String?
  proofImageUrl; // URL ảnh biên lai chuyển khoản ngân hàng (nếu có)
  final String? recordedBy; // Staff UID phê duyệt / ghi nhận giao dịch
  final String? rejectReason; // Lý do từ chối (nếu giao dịch bị hủy)
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.paymentId,
    required this.billId,
    required this.apartmentId,
    required this.residentId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.proofImageUrl,
    this.recordedBy,
    this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PaymentModel(
      paymentId: doc.id,
      billId: data['billId'] as String? ?? '',
      apartmentId: data['apartmentId'] as String? ?? '',
      residentId: data['residentId'] as String? ?? '',
      amount: (data['amount'] as num? ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      proofImageUrl: data['proofImageUrl'] as String?,
      recordedBy: data['recordedBy'] as String?,
      rejectReason: data['rejectReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billId': billId,
      'apartmentId': apartmentId,
      'residentId': residentId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'proofImageUrl': proofImageUrl,
      'recordedBy': recordedBy,
      'rejectReason': rejectReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
