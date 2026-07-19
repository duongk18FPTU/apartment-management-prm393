import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/complaint_model.dart';
import '../../../providers/complaint_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/complaint_status_chip.dart';
import '../../../widgets/loading_indicator.dart';

/// Admin/Staff — manage all complaints with status filter.
class ComplaintManageScreen extends StatefulWidget {
  const ComplaintManageScreen({super.key});

  @override
  State<ComplaintManageScreen> createState() => _ComplaintManageScreenState();
}

class _ComplaintManageScreenState extends State<ComplaintManageScreen> {
  ComplaintStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<ComplaintProvider>().loadAllComplaints(status: _filter);
  }

  Future<void> _onFilter(ComplaintStatus? status) async {
    setState(() => _filter = status);
    await context.read<ComplaintProvider>().loadAllComplaints(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Quản lý khiếu nại')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tất cả'),
                  selected: _filter == null,
                  onSelected: (_) => _onFilter(null),
                  selectedColor: DesignTokens.secondaryContainer,
                ),
                ...ComplaintStatus.values.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(s.label),
                      selected: _filter == s,
                      onSelected: (_) => _onFilter(s),
                      selectedColor: DesignTokens.secondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: DesignTokens.secondary,
              child: provider.isLoading && provider.complaints.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        LoadingIndicator.circular(),
                      ],
                    )
                  : provider.complaints.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 100),
                        Icon(
                          Icons.inbox_outlined,
                          size: 56,
                          color: DesignTokens.neutralVariant,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          provider.errorMessage ?? 'Không có khiếu nại nào',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: provider.complaints.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = provider.complaints[index];
                        return Material(
                          color: DesignTokens.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onTap: () => context.push(
                              AppRoutes.complaintDetail.replaceFirst(
                                ':id',
                                item.id,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                      ComplaintStatusChip(status: item.status),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Căn ${item.apartmentId} · ${dateFmt.format(item.createdAt)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: DesignTokens.neutralVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
