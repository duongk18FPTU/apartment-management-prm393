import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';
import '../models/payment_model.dart';
import '../utils/constants.dart';

class BillService {
  final FirebaseFirestore _firestore;

  BillService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách hóa đơn kèm bộ lọc linh hoạt cho Staff / Resident
  Future<List<BillModel>> getBills({
    String? apartmentId,
    String? billingMonth,
    String? status,
  }) async {
    Query query = _firestore.collection(AppCollections.bills);

    if (apartmentId != null && apartmentId.isNotEmpty) {
      query = query.where('apartmentId', isEqualTo: apartmentId);
    }
    if (billingMonth != null && billingMonth.isNotEmpty) {
      query = query.where('billingMonth', isEqualTo: billingMonth);
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    // Sắp xếp giảm dần theo ngày tạo
    query = query.orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => BillModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }

  /// Lấy chi tiết một hóa đơn cụ thể
  Future<BillModel?> getBillById(String billId) async {
    final doc = await _firestore
        .collection(AppCollections.bills)
        .doc(billId)
        .get();
    if (!doc.exists) return null;
    return BillModel.fromFirestore(doc);
  }

  /// Tạo hóa đơn mới (Staff)
  Future<String> createBill(BillModel bill) async {
    final docRef = await _firestore
        .collection(AppCollections.bills)
        .add(bill.toMap());
    return docRef.id;
  }

  /// Gửi yêu cầu xác nhận thanh toán thủ công từ Resident
  Future<void> submitPaymentRequest(PaymentModel payment) async {
    final batch = _firestore.batch();

    // 1. Tạo bản ghi payment mới
    final paymentRef = _firestore.collection('payments').doc();
    batch.set(paymentRef, payment.toMap());

    // 2. Chuyển trạng thái hóa đơn sang 'pending' chờ nhân viên duyệt
    final billRef = _firestore
        .collection(AppCollections.bills)
        .doc(payment.billId);
    batch.update(billRef, {
      'status': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Phê duyệt yêu cầu thanh toán (Staff ghi nhận tiền mặt hoặc duyệt chuyển khoản ngân hàng)
  Future<void> approvePayment(
    String paymentId,
    String billId,
    String staffId,
    String method,
  ) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    // 1. Cập nhật bản ghi payment thành 'approved'
    final paymentRef = _firestore.collection('payments').doc(paymentId);
    batch.update(paymentRef, {
      'status': 'approved',
      'recordedBy': staffId,
      'updatedAt': Timestamp.fromDate(now),
    });

    // 2. Cập nhật trạng thái hóa đơn thành 'paid'
    final billRef = _firestore.collection(AppCollections.bills).doc(billId);
    batch.update(billRef, {
      'status': 'paid',
      'paymentMethod': method,
      'paidAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  /// Từ chối yêu cầu thanh toán (Staff phát hiện biên lai lỗi hoặc sai thông tin)
  Future<void> rejectPayment(
    String paymentId,
    String billId,
    String staffId,
    String reason,
  ) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    // 1. Cập nhật bản ghi payment thành 'rejected' kèm lý do
    final paymentRef = _firestore.collection('payments').doc(paymentId);
    batch.update(paymentRef, {
      'status': 'rejected',
      'recordedBy': staffId,
      'rejectReason': reason,
      'updatedAt': Timestamp.fromDate(now),
    });

    // 2. Trả trạng thái hóa đơn về 'unpaid' để cư dân thực hiện lại
    final billRef = _firestore.collection(AppCollections.bills).doc(billId);
    batch.update(billRef, {
      'status': 'unpaid',
      'updatedAt': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  /// Lấy lịch sử giao dịch thanh toán
  Future<List<PaymentModel>> getPaymentsHistory({
    String? apartmentId,
    String? residentId,
  }) async {
    Query query = _firestore.collection('payments');

    if (apartmentId != null && apartmentId.isNotEmpty) {
      query = query.where('apartmentId', isEqualTo: apartmentId);
    }
    if (residentId != null && residentId.isNotEmpty) {
      query = query.where('residentId', isEqualTo: residentId);
    }

    query = query.orderBy('createdAt', descending: true);
    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) => PaymentModel.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }

  /// Tìm giao dịch chờ duyệt cho một hóa đơn cụ thể
  Future<PaymentModel?> getPendingPaymentForBill(String billId) async {
    final snap = await _firestore
        .collection('payments')
        .where('billId', isEqualTo: billId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return PaymentModel.fromFirestore(
      snap.docs.first as DocumentSnapshot<Map<String, dynamic>>,
    );
  }
}
