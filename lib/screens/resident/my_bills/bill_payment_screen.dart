import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/bill_model.dart';
import '../../../utils/vietnamese_formatters.dart';

class BillPaymentScreen extends StatefulWidget {
  final String billId;

  const BillPaymentScreen({super.key, required this.billId});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  BillModel? _bill;
  bool _localLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBillDetails();
  }

  void _loadBillDetails() {
    final provider = context.read<BillProvider>();
    setState(() {
      _bill = provider.bills.firstWhere((b) => b.billId == widget.billId);
      _localLoading = false;
    });
  }

  void _submitPayment() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Xác nhận thanh toán',
      message:
          'Bạn xác nhận đã thực hiện chuyển khoản số tiền này đến số tài khoản ban quản lý?',
    );

    if (confirm == true && mounted) {
      final user = context.read<AuthProvider>().userModel;
      final provider = context.read<BillProvider>();

      final success = await provider.payBill(
        billId: widget.billId,
        apartmentId: _bill!.apartmentId,
        residentId: user?.uid ?? 'resident_temp_uid',
        amount: _bill!.amount,
        method: 'bank_transfer',
        proofImageUrl: 'mock_proof_url.png', // Mô phỏng ảnh biên lai thanh toán
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Yêu cầu thanh toán đã được gửi! Vui lòng chờ BQL đối soát và phê duyệt.',
            ),
            backgroundColor: DesignTokens.tertiary,
          ),
        );
        context.pop();
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
      appBar: AppBar(title: const Text('Thanh Toán Hóa Đơn')),
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
                          _buildRow(
                            'Căn hộ:',
                            'Phòng ${_bill!.apartmentId}',
                            textTheme,
                          ),
                          _buildRow(
                            'Tháng:',
                            'Tháng ${_bill!.billingMonth}',
                            textTheme,
                          ),
                          _buildRow(
                            'Số tiền:',
                            VietnameseFormatters.currency.format(_bill!.amount),
                            textTheme,
                            isPrice: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Mock Bank Account Information (Dữ liệu mẫu thực tế của quản lý chung cư)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin chuyển khoản',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: AppSpacing.md),
                          _buildRow(
                            'Ngân hàng:',
                            'VPBank (Việt Nam Thịnh Vượng)',
                            textTheme,
                          ),
                          _buildRow(
                            'Số tài khoản:',
                            '9876543210',
                            textTheme,
                            isBold: true,
                          ),
                          _buildRow(
                            'Chủ tài khoản:',
                            'BAN QUẢN LÝ CHUNG CƯ HAVEN',
                            textTheme,
                          ),
                          _buildRow(
                            'Nội dung CK:',
                            'Phòng ${_bill!.apartmentId} CK ${_bill!.type.label}',
                            textTheme,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_bill!.status == 'unpaid')
              ElevatedButton(
                onPressed: _submitPayment,
                child: const Text('Tôi Đã Chuyển Khoản'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String val,
    TextTheme textTheme, {
    bool isBold = false,
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Tránh lệch hàng khi xuống dòng
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: DesignTokens.neutralVariant,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ), // Tạo khoảng cách an toàn giữa cột trái và cột phải
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.end, // Canh đều lề phải cực đẹp
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: (isBold || isPrice)
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: isPrice ? DesignTokens.secondary : null,
                fontFamily: isPrice ? 'Outfit' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
