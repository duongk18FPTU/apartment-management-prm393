import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/visitor_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/visitor_provider.dart';
import '../../../services/visitor_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// Staff — list visitors + check-in / check-out (Firestore).
class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key, this.embedded = true});

  /// When true (tab inside StaffHome), hide back button.
  final bool embedded;

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkIn(VisitorModel visitor) async {
    final staffId = context.read<AuthProvider>().userModel?.uid ?? '';
    final provider = context.read<VisitorProvider>();
    final ok = await provider.checkIn(
      visitorId: visitor.id,
      staffId: staffId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã check-in ${visitor.visitorName}'
              : (provider.errorMessage ?? 'Check-in thất bại'),
        ),
        backgroundColor: ok ? DesignTokens.tertiary : DesignTokens.error,
      ),
    );
  }

  Future<void> _checkOut(VisitorModel visitor) async {
    final provider = context.read<VisitorProvider>();
    final ok = await provider.checkOut(visitor.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã check-out ${visitor.visitorName}'
              : (provider.errorMessage ?? 'Check-out thất bại'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VisitorProvider>();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Khách viếng thăm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, SĐT, căn hộ...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: DesignTokens.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _StatChip(
                  label: 'Tổng',
                  value: '${provider.visitors.length}',
                  color: DesignTokens.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'Trong tòa',
                  value: '${provider.insideCount}',
                  color: DesignTokens.tertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.loadAll,
              color: DesignTokens.secondary,
              child: provider.isLoading && provider.visitors.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        LoadingIndicator.circular(),
                      ],
                    )
                  : provider.errorMessage != null && provider.visitors.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: ErrorState(
                            message: provider.errorMessage!,
                            onRetry: provider.loadAll,
                          ),
                        ),
                      ],
                    )
                  : provider.filteredVisitors.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: const EmptyState(
                            icon: Icons.badge_outlined,
                            title: 'Không có khách',
                            message:
                                'Chưa có đăng ký khách, hoặc không khớp tìm kiếm.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: provider.filteredVisitors.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final v = provider.filteredVisitors[index];
                        return _VisitorCard(
                          visitor: v,
                          dateFmt: dateFmt,
                          busy: provider.isSubmitting,
                          onCheckIn: () => _checkIn(v),
                          onCheckOut: () => _checkOut(v),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VisitorCard extends StatelessWidget {
  const _VisitorCard({
    required this.visitor,
    required this.dateFmt,
    required this.busy,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final VisitorModel visitor;
  final DateFormat dateFmt;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  @override
  Widget build(BuildContext context) {
    final status = visitor.status;
    final canCheckIn = status == VisitorStatus.registered;
    final canCheckOut = status == VisitorStatus.checkedIn;

    return Material(
      color: DesignTokens.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    visitor.visitorName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    VisitorStatus.label(status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: DesignTokens.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${visitor.visitorPhone} · Căn ${visitor.apartmentId}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.neutralVariant,
              ),
            ),
            Text(
              'Mục đích: ${visitor.purpose}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (visitor.expectedTime != null)
              Text(
                'Dự kiến: ${dateFmt.format(visitor.expectedTime!)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
              ),
            if (visitor.checkInTime != null)
              Text(
                'Check-in: ${dateFmt.format(visitor.checkInTime!)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            if (visitor.checkOutTime != null)
              Text(
                'Check-out: ${dateFmt.format(visitor.checkOutTime!)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            if (canCheckIn || canCheckOut) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (canCheckIn)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: busy ? null : onCheckIn,
                        child: const Text('Check-in'),
                      ),
                    ),
                  if (canCheckOut)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: busy ? null : onCheckOut,
                        child: const Text('Check-out'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
