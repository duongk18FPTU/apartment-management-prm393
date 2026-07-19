import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/request_model.dart';
import '../../../providers/request_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/request_status_chip.dart';

/// Staff — manage all maintenance requests with status filter.
class RequestManageScreen extends StatefulWidget {
  const RequestManageScreen({super.key});

  @override
  State<RequestManageScreen> createState() => _RequestManageScreenState();
}

class _RequestManageScreenState extends State<RequestManageScreen> {
  RequestStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<RequestProvider>().loadAllRequests(status: _filter);
  }

  Future<void> _onFilter(RequestStatus? status) async {
    setState(() => _filter = status);
    await context.read<RequestProvider>().loadAllRequests(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Quản lý yêu cầu')),
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
                _FilterChip(
                  label: 'Tất cả',
                  selected: _filter == null,
                  onSelected: () => _onFilter(null),
                ),
                ...RequestStatus.values.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _FilterChip(
                      label: s.label,
                      selected: _filter == s,
                      onSelected: () => _onFilter(s),
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
              child: provider.isLoading && provider.requests.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        LoadingIndicator.circular(),
                      ],
                    )
                  : provider.errorMessage != null && provider.requests.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        const SizedBox(height: 80),
                        Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: ElevatedButton(
                            onPressed: _load,
                            child: const Text('Thử lại'),
                          ),
                        ),
                      ],
                    )
                  : provider.requests.isEmpty
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
                          'Không có yêu cầu nào',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: provider.requests.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = provider.requests[index];
                        return Material(
                          color: DesignTokens.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onTap: () => context.push(
                              AppRoutes.requestDetail.replaceFirst(
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
                                          item.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      RequestStatusChip(status: item.status),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '${item.category.label} · Căn ${item.apartmentId}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: DesignTokens.secondary,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    dateFmt.format(item.createdAt),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: DesignTokens.secondaryContainer,
      checkmarkColor: DesignTokens.secondary,
      labelStyle: TextStyle(
        color: selected ? DesignTokens.secondary : DesignTokens.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
