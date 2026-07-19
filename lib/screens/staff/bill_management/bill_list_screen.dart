import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../providers/bill_provider.dart';
import 'widgets/bill_filter_bar.dart';
import 'widgets/bill_card.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  String? _selectedStatus;
  String? _selectedMonth;

  final List<String> _statuses = ['unpaid', 'paid', 'pending', 'overdue'];
  final List<String> _months = ['2026-05', '2026-06', '2026-07', '2026-08'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBills();
    });
  }

  void _fetchBills() {
    context.read<BillProvider>().loadBills(
      billingMonth: _selectedMonth,
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Hóa đơn ban quản lý'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchBills,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/staff/bills/create'),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          BillFilterBar(
            selectedStatus: _selectedStatus,
            selectedMonth: _selectedMonth,
            statuses: _statuses,
            months: _months,
            onStatusChanged: (val) {
              setState(() => _selectedStatus = val);
              _fetchBills();
            },
            onMonthChanged: (val) {
              setState(() => _selectedMonth = val);
              _fetchBills();
            },
          ),
          Expanded(child: _buildBillsContent(billProvider, textTheme)),
        ],
      ),
    );
  }

  Widget _buildBillsContent(BillProvider provider, TextTheme textTheme) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(DesignTokens.secondary),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return ErrorState(message: provider.errorMessage!, onRetry: _fetchBills);
    }

    if (provider.bills.isEmpty) {
      return EmptyState(
        title: 'Chưa có hóa đơn nào',
        message: 'Hãy thử đổi bộ lọc hoặc tạo một hóa đơn mới cho cư dân.',
        icon: Icons.receipt_long_outlined,
        actionLabel: 'Tải lại dữ liệu',
        onActionPressed: _fetchBills,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: provider.bills.length,
      itemBuilder: (context, index) {
        final bill = provider.bills[index];
        return BillCard(
          bill: bill,
          onTap: () => context.push('/staff/bills/${bill.billId}'),
        );
      },
    );
  }
}
