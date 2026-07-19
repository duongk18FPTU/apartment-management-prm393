import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/status_badge.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/vietnamese_formatters.dart';
import '../../../models/bill_model.dart';

class MyBillsScreen extends StatefulWidget {
  const MyBillsScreen({super.key});

  @override
  State<MyBillsScreen> createState() => _MyBillsScreenState();
}

class _MyBillsScreenState extends State<MyBillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyBills();
    });
  }

  void _fetchMyBills() {
    final userModel = context.read<AuthProvider>().userModel;
    if (userModel?.apartmentId != null) {
      context.read<BillProvider>().loadBills(
        apartmentId: userModel!.apartmentId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final userModel = context.watch<AuthProvider>().userModel;

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
        title: Text(
          'Hóa đơn căn hộ ${userModel?.apartmentId ?? ""}',
          style: const TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(child: _buildMyBillsContent(billProvider)),
    );
  }

  Widget _buildMyBillsContent(BillProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF091426)),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: _fetchMyBills,
      );
    }

    if (provider.bills.isEmpty) {
      return EmptyState(
        title: 'Không có hóa đơn',
        message:
            'Tuyệt vời! Hiện tại căn hộ của bạn không có hóa đơn nào cần thanh toán.',
        icon: Icons.celebration_outlined,
        actionLabel: 'Tải lại',
        onActionPressed: _fetchMyBills,
      );
    }

    // Find first unpaid bill for general warning banner
    final unpaidBills = provider.bills
        .where((b) => b.status == 'unpaid' || b.status == 'overdue')
        .toList();

    return Column(
      children: [
        if (unpaidBills.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Container(
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
                      'Hạn thanh toán gần nhất: ${VietnameseFormatters.date.format(unpaidBills.first.dueDate)}',
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
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            itemCount: provider.bills.length,
            itemBuilder: (context, index) {
              final bill = provider.bills[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildBillItemCard(bill),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBillItemCard(BillModel bill) {
    IconData categoryIcon;
    Color iconBg;

    switch (bill.type) {
      case BillType.water:
        categoryIcon = Icons.water_drop_rounded;
        iconBg = const Color(0xFFE8F0FE);
        break;
      case BillType.electricity:
        categoryIcon = Icons.bolt_rounded;
        iconBg = const Color(0xFFFEF7E0);
        break;
      case BillType.parking:
        categoryIcon = Icons.local_parking_rounded;
        iconBg = const Color(0xFFF1F3F4);
        break;
      case BillType.service:
        categoryIcon = Icons.home_repair_service_rounded;
        iconBg = const Color(0xFFE6F4EA);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02091426),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () async {
            await context.push('/resident/bills/${bill.billId}/pay');
            _fetchMyBills();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoryIcon,
                    color: const Color(0xFF091426),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.type.label,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kỳ tháng ${bill.billingMonth} · Hạn: ${VietnameseFormatters.date.format(bill.dueDate)}',
                        style: const TextStyle(
                          color: Color(0xFF75777D),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      VietnameseFormatters.currency.format(bill.amount),
                      style: const TextStyle(
                        color: Color(0xFF091426),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    StatusBadge.bill(
                      BillStatus.values.firstWhere(
                        (e) => e.name == bill.status,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
