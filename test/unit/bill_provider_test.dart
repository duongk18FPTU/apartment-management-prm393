import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/bill_model.dart';
import 'package:prm393_project/models/payment_model.dart';
import 'package:prm393_project/providers/bill_provider.dart';
import 'package:prm393_project/services/bill_service.dart';

// Bộ giả lập (Fake/Mock) thủ công cho BillService để viết unit test độc lập
class FakeBillService implements BillService {
  final List<BillModel> mockBills = [];
  final List<PaymentModel> mockPayments = [];
  bool shouldThrowError = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<BillModel>> getBills({
    String? apartmentId,
    String? billingMonth,
    String? status,
  }) async {
    if (shouldThrowError) {
      throw Exception('Database connection failed');
    }
    return mockBills.where((b) {
      if (apartmentId != null && b.apartmentId != apartmentId) return false;
      if (billingMonth != null && b.billingMonth != billingMonth) return false;
      if (status != null && b.status != status) return false;
      return true;
    }).toList();
  }

  @override
  Future<String> createBill(BillModel bill) async {
    if (shouldThrowError) {
      throw Exception('Write failed');
    }
    mockBills.add(bill);
    return 'new_bill_id';
  }

  @override
  Future<void> submitPaymentRequest(PaymentModel payment) async {
    if (shouldThrowError) {
      throw Exception('Payment request failed');
    }
    mockPayments.add(payment);
  }

  @override
  Future<void> approvePayment(
    String paymentId,
    String billId,
    String staffId,
    String method,
  ) async {
    if (shouldThrowError) {
      throw Exception('Approval failed');
    }
    final index = mockBills.indexWhere((b) => b.billId == billId);
    if (index != -1) {
      mockBills[index] = mockBills[index].copyWith(
        status: 'paid',
        paymentMethod: method,
        paidAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> rejectPayment(
    String paymentId,
    String billId,
    String staffId,
    String reason,
  ) async {
    if (shouldThrowError) {
      throw Exception('Rejection failed');
    }
    final index = mockBills.indexWhere((b) => b.billId == billId);
    if (index != -1) {
      mockBills[index] = mockBills[index].copyWith(status: 'unpaid');
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsHistory({
    String? apartmentId,
    String? residentId,
  }) async {
    if (shouldThrowError) {
      throw Exception('Fetch failed');
    }
    return mockPayments;
  }

  @override
  Future<PaymentModel?> getPendingPaymentForBill(String billId) async {
    try {
      return mockPayments.firstWhere(
        (p) => p.billId == billId && p.status == 'pending',
      );
    } catch (_) {
      return null;
    }
  }
}

void main() {
  group('BillModel Unit Tests', () {
    test('copyWith updates properties correctly', () {
      final now = DateTime.now();
      final bill = BillModel(
        billId: '1',
        apartmentId: '301',
        residentId: 'res1',
        type: BillType.electricity,
        amount: 150000,
        billingMonth: '2026-07',
        dueDate: now,
        status: 'unpaid',
        createdBy: 'staff1',
        createdAt: now,
        updatedAt: now,
      );

      final updatedBill = bill.copyWith(status: 'paid', paymentMethod: 'cash');

      expect(updatedBill.status, 'paid');
      expect(updatedBill.paymentMethod, 'cash');
      expect(updatedBill.apartmentId, '301'); // Giữ nguyên thuộc tính khác
    });
  });

  group('BillProvider Unit Tests with FakeBillService', () {
    late FakeBillService fakeService;
    late BillProvider provider;

    setUp(() {
      fakeService = FakeBillService();
      provider = BillProvider(billService: fakeService);
    });

    test('loadBills sets bills and updates loading state', () async {
      final now = DateTime.now();
      fakeService.mockBills.add(
        BillModel(
          billId: '1',
          apartmentId: '301',
          residentId: 'res1',
          type: BillType.electricity,
          amount: 150000,
          billingMonth: '2026-07',
          dueDate: now,
          status: 'unpaid',
          createdBy: 'staff1',
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(provider.isLoading, isFalse);
      expect(provider.bills, isEmpty);

      final future = provider.loadBills();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.bills.length, 1);
      expect(provider.bills.first.apartmentId, '301');
      expect(provider.errorMessage, isNull);
    });

    test('loadBills handles errors correctly', () async {
      fakeService.shouldThrowError = true;

      await provider.loadBills();

      expect(provider.isLoading, isFalse);
      expect(provider.bills, isEmpty);
      expect(provider.errorMessage, contains('Database connection failed'));
    });

    test('createNewBill adds a bill', () async {
      final now = DateTime.now();
      final bill = BillModel(
        billId: '1',
        apartmentId: '301',
        residentId: 'res1',
        type: BillType.electricity,
        amount: 150000,
        billingMonth: '2026-07',
        dueDate: now,
        status: 'unpaid',
        createdBy: 'staff1',
        createdAt: now,
        updatedAt: now,
      );

      final success = await provider.createNewBill(bill);

      expect(success, isTrue);
      expect(fakeService.mockBills.length, 1);
      expect(fakeService.mockBills.first.apartmentId, '301');
    });

    test('payBill submits a payment request', () async {
      final success = await provider.payBill(
        billId: '1',
        apartmentId: '301',
        residentId: 'res1',
        amount: 150000,
        method: 'bank_transfer',
      );

      expect(success, isTrue);
      expect(fakeService.mockPayments.length, 1);
      expect(fakeService.mockPayments.first.billId, '1');
      expect(fakeService.mockPayments.first.status, 'pending');
    });
  });
}
