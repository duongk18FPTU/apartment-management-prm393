import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label!'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF091426),
      ),
    );
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
        proofImageUrl: 'mock_proof_url.png',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Yêu cầu thanh toán đã được gửi! Vui lòng chờ BQL đối soát và phê duyệt.',
            ),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        context.pop();
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

    final String accountNo = '9876543210';
    final String transferRef =
        'P${_bill!.apartmentId} Thanh toan ${_bill!.type.name}';

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
          'Thanh toán hóa đơn',
          style: TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Warning Banner
                    if (_bill!.status == 'unpaid')
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.priority_high_rounded,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hạn thanh toán: ${VietnameseFormatters.date.format(_bill!.dueDate)}',
                                style: const TextStyle(
                                  color: Color(0xFFB45309),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Bill Details Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                              const Text(
                                'Tổng số tiền cần thanh toán',
                                style: TextStyle(
                                  color: Color(0xFF75777D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              StatusBadge.bill(
                                BillStatus.values.firstWhere(
                                  (e) => e.name == _bill!.status,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            VietnameseFormatters.currency.format(_bill!.amount),
                            style: const TextStyle(
                              color: Color(0xFF091426),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            icon: _bill!.type == BillType.water
                                ? Icons.water_drop_rounded
                                : _bill!.type == BillType.electricity
                                ? Icons.bolt_rounded
                                : _bill!.type == BillType.parking
                                ? Icons.local_parking_rounded
                                : Icons.home_repair_service_rounded,
                            title: 'Dịch vụ: ${_bill!.type.label}',
                            amount: VietnameseFormatters.currency.format(
                              _bill!.amount,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bank Transfer Instructions Card
                    Row(
                      children: const [
                        Icon(
                          Icons.account_balance_rounded,
                          color: Color(0xFF091426),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hướng dẫn chuyển khoản ngân hàng',
                          style: TextStyle(
                            color: Color(0xFF091426),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bank info row
                                const Text(
                                  'NGÂN HÀNG',
                                  style: TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: Color(0xFF091426),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'VPBank (Việt Nam Thịnh Vượng)',
                                      style: TextStyle(
                                        color: Color(0xFF091426),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Account number block
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'SỐ TÀI KHOẢN',
                                            style: TextStyle(
                                              color: Color(0xFF75777D),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            accountNo,
                                            style: const TextStyle(
                                              color: Color(0xFF091426),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _copyToClipboard(
                                          accountNo,
                                          'Số tài khoản',
                                        ),
                                        icon: const Icon(
                                          Icons.content_copy_rounded,
                                          size: 14,
                                        ),
                                        label: const Text('Sao chép'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF091426,
                                          ),
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Account Owner name
                                const Text(
                                  'CHỦ TÀI KHOẢN',
                                  style: TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'BAN QUẢN LÝ CHUNG CƯ HAVEN',
                                  style: TextStyle(
                                    color: Color(0xFF091426),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Amount details
                                const Text(
                                  'SỐ TIỀN',
                                  style: TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  VietnameseFormatters.currency.format(
                                    _bill!.amount,
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF091426),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Transfer reference block
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0x04091426),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'NỘI DUNG CHUYỂN KHOẢN',
                                              style: TextStyle(
                                                color: Color(0xFF75777D),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              transferRef,
                                              style: const TextStyle(
                                                color: Color(0xFF091426),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => _copyToClipboard(
                                          transferRef,
                                          'Nội dung chuyển khoản',
                                        ),
                                        icon: const Icon(
                                          Icons.content_copy_rounded,
                                          color: Color(0xFF091426),
                                          size: 18,
                                        ),
                                        tooltip: 'Sao chép nội dung',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Reconciliation notes footer
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF75777D),
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Hệ thống sẽ tự động cập nhật trạng thái thanh toán sau khi Ban quản lý đối soát khớp thông tin chuyển khoản. Vui lòng chụp và giữ lại biên lai để đối chiếu.',
                                    style: TextStyle(
                                      color: Color(0xFF75777D),
                                      fontSize: 11,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Submit Button Action Bar
            if (_bill!.status == 'unpaid')
              Container(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF091426),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Tôi đã chuyển khoản',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String amount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF091426), size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF091426),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF091426),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
