import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../providers/bill_provider.dart';
import '../../../models/bill_model.dart';
import '../../../models/payment_model.dart';
import '../../../utils/vietnamese_formatters.dart';

class BillDetailScreen extends StatefulWidget {
  final String billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  BillModel? _bill;
  PaymentModel? _pendingPayment;
  bool _localLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  void _loadBillDetails() async {
    final provider = context.read<BillProvider>();
    await provider.loadBills();
    if (mounted) {
      final bill = provider.bills.firstWhere((b) => b.billId == widget.billId);
      PaymentModel? pending;
      if (bill.status == 'pending') {
        pending = await provider.getPendingPaymentForBill(bill.billId);
      }
      setState(() {
        _bill = bill;
        _pendingPayment = pending;
        _localLoading = false;
      });
    }
  }

  void _recordCashPayment() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Ghi nhận tiền mặt',
      message: 'Bạn xác nhận đã thu đủ số tiền mặt cho hóa đơn này?',
    );

    if (confirm == true && mounted) {
      final provider = context.read<BillProvider>();
      final success = await provider.confirmPaymentApproved(
        paymentId: 'manual_${widget.billId}',
        billId: widget.billId,
        staffId: 'staff_temp_uid',
        method: 'cash',
      );
      if (success && mounted) {
        _loadBillDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã ghi nhận thanh toán tiền mặt thành công!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      }
    }
  }

  void _approvePendingPayment() async {
    if (_pendingPayment == null) return;
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Phê duyệt chuyển khoản',
      message:
          'Bạn xác nhận số tiền chuyển khoản của cư dân đã khớp và hợp lệ?',
    );

    if (confirm == true && mounted) {
      final provider = context.read<BillProvider>();
      final success = await provider.confirmPaymentApproved(
        paymentId: _pendingPayment!.paymentId,
        billId: widget.billId,
        staffId: 'staff_temp_uid',
        method: 'bank_transfer',
      );
      if (success && mounted) {
        _loadBillDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã phê duyệt thanh toán chuyển khoản thành công!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      }
    }
  }

  void _rejectPendingPayment() async {
    if (_pendingPayment == null) return;

    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Từ chối giao dịch',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vui lòng nhập lý do từ chối thanh toán:'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Biên lai không khớp / Sai số tiền',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A),
            ),
            child: const Text('TỪ CHỐI'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final reason = reasonController.text.trim();
      if (reason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập lý do từ chối!')),
        );
        return;
      }
      final provider = context.read<BillProvider>();
      final success = await provider.confirmPaymentRejected(
        paymentId: _pendingPayment!.paymentId,
        billId: widget.billId,
        staffId: 'staff_temp_uid',
        reason: reason,
      );
      if (success && mounted) {
        _loadBillDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yêu cầu thanh toán đã bị từ chối.'),
            backgroundColor: Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bill == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: Text('Không tìm thấy hóa đơn')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF091426)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chi tiết hóa đơn',
          style: TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room & ID Header Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05091426),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Phòng ${_bill!.apartmentId}',
                          style: const TextStyle(
                            color: Color(0xFF091426),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        StatusBadge.bill(
                          BillStatus.values.firstWhere(
                            (e) => e.name == _bill!.status,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mã HĐ: ${_bill!.billId.substring(0, _bill!.billId.length > 8 ? 8 : _bill!.billId.length).toUpperCase()}',
                      style: const TextStyle(
                        color: Color(0xFF75777D),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'THÁNG',
                              style: TextStyle(
                                color: Color(0xFF75777D),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              VietnameseFormatters.billingMonth(
                                _bill!.billingMonth,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF091426),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'HẠN THANH TOÁN',
                              style: TextStyle(
                                color: Color(0xFF75777D),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              VietnameseFormatters.date.format(_bill!.dueDate),
                              style: const TextStyle(
                                color: Color(0xFF091426),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Breakdown Section
              const Text(
                'CHI TIẾT DỊCH VỤ',
                style: TextStyle(
                  color: Color(0xFF75777D),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05091426),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildBreakdownItem(
                      icon: _bill!.type == BillType.water
                          ? Icons.water_drop_rounded
                          : _bill!.type == BillType.electricity
                          ? Icons.bolt_rounded
                          : _bill!.type == BillType.parking
                          ? Icons.local_parking_rounded
                          : Icons.apartment_rounded,
                      title: 'Phí ${_bill!.type.label}',
                      value: VietnameseFormatters.currency.format(
                        _bill!.amount,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(
                        color: Color(0xFF8590A6),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      VietnameseFormatters.currency.format(_bill!.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Pending proof image section if waiting approval
              if (_bill!.status == 'pending' && _pendingPayment != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'BIÊN LAI CHỜ PHÊ DUYỆT',
                  style: TextStyle(
                    color: Color(0xFF75777D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Số tiền gửi:',
                        VietnameseFormatters.currency.format(
                          _pendingPayment!.amount,
                        ),
                      ),
                      _buildDetailRow(
                        'Phương thức:',
                        _pendingPayment!.paymentMethod == 'cash'
                            ? 'Tiền mặt'
                            : 'Chuyển khoản',
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 36,
                                color: Color(0xFF75777D),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Biên lai chuyển khoản của cư dân\n(mock_proof_url.png)',
                                style: TextStyle(
                                  color: Color(0xFF75777D),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action buttons
              if (_bill!.status == 'unpaid')
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _recordCashPayment,
                    icon: const Icon(Icons.payments_rounded),
                    label: const Text('Xác nhận Tiền mặt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF091426),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              if (_bill!.status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: _rejectPendingPayment,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFBA1A1A),
                          ),
                          label: const Text(
                            'Từ Chối',
                            style: TextStyle(
                              color: Color(0xFFBA1A1A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFBA1A1A),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _approvePendingPayment,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Duyệt Chuyển Khoản'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF091426),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x0A091426),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF091426), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF091426),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF091426),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF75777D), fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF091426),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
