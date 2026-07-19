import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/vietnamese_formatters.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  void _fetchHistory() {
    final userModel = context.read<AuthProvider>().userModel;
    if (userModel?.apartmentId != null) {
      context.read<BillProvider>().loadPaymentsHistory(
        apartmentId: userModel!.apartmentId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchHistory,
          ),
        ],
      ),
      body: _buildHistoryContent(billProvider, textTheme),
    );
  }

  Widget _buildHistoryContent(BillProvider provider, TextTheme textTheme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return ErrorState(
        message: provider.errorMessage!,
        onRetry: _fetchHistory,
      );
    }

    if (provider.payments.isEmpty) {
      return EmptyState(
        title: 'Chưa có giao dịch nào',
        message: 'Lịch sử thanh toán các hóa đơn của bạn sẽ xuất hiện tại đây.',
        icon: Icons.history_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: provider.payments.length,
      itemBuilder: (context, index) {
        final payment = provider.payments[index];

        // Map payment status to BillStatus for the badge
        final badgeStatus = switch (payment.status) {
          'approved' => BillStatus.paid,
          'rejected' => BillStatus.overdue,
          _ => BillStatus.pending,
        };

        final badgeLabel = switch (payment.status) {
          'approved' => 'Đã duyệt',
          'rejected' => 'Bị từ chối',
          _ => 'Chờ duyệt',
        };

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      payment.paymentMethod == 'cash'
                          ? 'Tiền mặt'
                          : 'Chuyển khoản VPBank',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatusBadge(
                      label: badgeLabel,
                      textColor: StatusBadge.bill(badgeStatus).textColor,
                      backgroundColor: StatusBadge.bill(
                        badgeStatus,
                      ).backgroundColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã hóa đơn: #${payment.billId.substring(0, payment.billId.length > 6 ? 6 : payment.billId.length)}',
                          style: textTheme.bodyMedium,
                        ),
                        Text(
                          VietnameseFormatters.dateTime.format(
                            payment.createdAt,
                          ),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Text(
                      VietnameseFormatters.currency.format(payment.amount),
                      style: textTheme.titleLarge?.copyWith(
                        color: DesignTokens.onBackground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (payment.status == 'rejected' &&
                    payment.rejectReason != null) ...[
                  const Divider(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      'Lý do từ chối: ${payment.rejectReason}',
                      style: textTheme.bodySmall?.copyWith(
                        color: DesignTokens.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
