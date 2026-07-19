import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/auth_provider.dart';

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final billProvider = context.watch<BillProvider>();
    final userModel = context.watch<AuthProvider>().userModel;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: Text('Căn hộ ${userModel?.apartmentId ?? "Của Tôi"} - Hóa Đơn'),
      ),
      body: _buildMyBillsContent(billProvider, textTheme),
    );
  }

  Widget _buildMyBillsContent(BillProvider provider, TextTheme textTheme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
        message: 'Tuyệt vời! Hiện tại căn hộ của bạn không có hóa đơn dư nợ.',
        icon: Icons.celebration_outlined,
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: provider.bills.length,
      itemBuilder: (context, index) {
        final bill = provider.bills[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            borderRadius: AppRadius.borderMd,
            onTap: () => context.push('/resident/bills/${bill.billId}/pay'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.type.label,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Hạn nộp: ${DateFormat('dd/MM/yyyy').format(bill.dueDate)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(bill.amount),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
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
        );
      },
    );
  }
}
