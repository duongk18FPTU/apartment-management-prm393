import 'package:flutter/foundation.dart';
import '../models/bill_model.dart';
import '../models/payment_model.dart';
import '../services/bill_service.dart';

class BillProvider extends ChangeNotifier {
  final BillService _billService;

  BillProvider({BillService? billService})
    : _billService = billService ?? BillService();

  List<BillModel> _bills = [];
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BillModel> get bills => _bills;
  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Tải danh sách hóa đơn theo bộ lọc
  Future<void> loadBills({
    String? apartmentId,
    String? billingMonth,
    String? status,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _bills = await _billService.getBills(
        apartmentId: apartmentId,
        billingMonth: billingMonth,
        status: status,
      );
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách hóa đơn: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Tạo hóa đơn mới (Staff)
  Future<bool> createNewBill(BillModel bill) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _billService.createBill(bill);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi tạo hóa đơn: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cư dân gửi xác nhận thanh toán (Thủ công hoặc CK ngân hàng)
  Future<bool> payBill({
    required String billId,
    required String apartmentId,
    required String residentId,
    required double amount,
    required String method,
    String? proofImageUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final now = DateTime.now();
    final payment = PaymentModel(
      paymentId: '', // Sinh tự động bởi Firestore
      billId: billId,
      apartmentId: apartmentId,
      residentId: residentId,
      amount: amount,
      paymentMethod: method,
      status: 'pending',
      proofImageUrl: proofImageUrl,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _billService.submitPaymentRequest(payment);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi gửi yêu cầu thanh toán: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Phê duyệt hóa đơn thanh toán (Staff)
  Future<bool> confirmPaymentApproved({
    required String paymentId,
    required String billId,
    required String staffId,
    required String method,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _billService.approvePayment(paymentId, billId, staffId, method);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi duyệt thanh toán: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Từ chối giao dịch thanh toán lỗi (Staff)
  Future<bool> confirmPaymentRejected({
    required String paymentId,
    required String billId,
    required String staffId,
    required String reason,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _billService.rejectPayment(paymentId, billId, staffId, reason);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi từ chối giao dịch: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Tải lịch sử thanh toán
  Future<void> loadPaymentsHistory({
    String? apartmentId,
    String? residentId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _payments = await _billService.getPaymentsHistory(
        apartmentId: apartmentId,
        residentId: residentId,
      );
    } catch (e) {
      _errorMessage = 'Không thể tải lịch sử thanh toán: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Tìm bản ghi thanh toán chờ duyệt của hóa đơn
  Future<PaymentModel?> getPendingPaymentForBill(String billId) async {
    try {
      return await _billService.getPendingPaymentForBill(billId);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
