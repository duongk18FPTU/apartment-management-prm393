import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    await provider.loadBills(); // Load danh sách mới nhất
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
        paymentId: 'manual_${widget.billId}', // Sinh ID giao dịch thủ công
        billId: widget.billId,
        staffId: 'staff_temp_uid',
        method: 'cash',
      );
      if (success && mounted) {
        _loadBillDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã ghi nhận thanh toán tiền mặt thành công!'),
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
              backgroundColor: DesignTokens.error,
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
          const SnackBar(content: Text('Yêu cầu thanh toán đã bị từ chối.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (_localLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_bill == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy hóa đơn')),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Chi Tiết Hóa Đơn')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _bill!.type.label,
                                style: textTheme.headlineSmall?.copyWith(
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
                          const Divider(height: AppSpacing.lg),
                          _buildDetailRow(
                            'Căn hộ:',
                            'Phòng ${_bill!.apartmentId}',
                            textTheme,
                          ),
                          _buildDetailRow(
                            'Tháng:',
                            VietnameseFormatters.billingMonth(
                              _bill!.billingMonth,
                            ),
                            textTheme,
                          ),
                          _buildDetailRow(
                            'Hạn nộp:',
                            VietnameseFormatters.date.format(_bill!.dueDate),
                            textTheme,
                          ),
                          _buildDetailRow(
                            'Ngày tạo:',
                            VietnameseFormatters.date.format(_bill!.createdAt),
                            textTheme,
                          ),
                          if (_bill!.status == 'paid') ...[
                            _buildDetailRow(
                              'Ngày thanh toán:',
                              VietnameseFormatters.date.format(
                                _bill!.paidAt ?? DateTime.now(),
                              ),
                              textTheme,
                            ),
                            _buildDetailRow(
                              'Hình thức:',
                              _bill!.paymentMethod == 'cash'
                                  ? 'Tiền mặt'
                                  : 'Chuyển khoản',
                              textTheme,
                            ),
                          ],
                          const Divider(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TỔNG TIỀN:',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                VietnameseFormatters.currency.format(
                                  _bill!.amount,
                                ),
                                style: textTheme.headlineMedium?.copyWith(
                                  color: DesignTokens.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_bill!.status == 'pending' && _pendingPayment != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biên lai chờ duyệt',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: AppSpacing.md),
                            _buildDetailRow(
                              'Số tiền gửi:',
                              VietnameseFormatters.currency.format(
                                _pendingPayment!.amount,
                              ),
                              textTheme,
                            ),
                            _buildDetailRow(
                              'Phương thức:',
                              _pendingPayment!.paymentMethod == 'cash'
                                  ? 'Tiền mặt'
                                  : 'Chuyển khoản',
                              textTheme,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: DesignTokens.surfaceVariant,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      size: 40,
                                      color: DesignTokens.neutralVariant,
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Biên lai chuyển khoản ngân hàng\n(mock_proof_url.png)',
                                      style: TextStyle(
                                        color: DesignTokens.neutralVariant,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
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
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_bill!.status == 'unpaid')
              ElevatedButton.icon(
                onPressed: _recordCashPayment,
                icon: const Icon(Icons.attach_money_rounded),
                label: const Text('Ghi Nhận Tiền Mặt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.tertiary,
                ),
              ),
            if (_bill!.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _rejectPendingPayment,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: DesignTokens.error,
                      ),
                      label: const Text(
                        'Từ Chối',
                        style: TextStyle(color: DesignTokens.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: DesignTokens.error,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _approvePendingPayment,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Duyệt Chuyển Khoản'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignTokens.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Tránh lệch hàng
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: DesignTokens.neutralVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
