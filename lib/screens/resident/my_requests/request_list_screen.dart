import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/request_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/request_status_chip.dart';

/// Resident — list of their own maintenance requests.
class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().userModel?.uid;
    if (uid == null) return;
    await context.read<RequestProvider>().loadResidentRequests(uid);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Yêu cầu của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.requestCreate),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gửi yêu cầu'),
      ),
      body: RefreshIndicator(
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
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: DesignTokens.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.handyman_outlined,
                    size: 56,
                    color: DesignTokens.neutralVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chưa có yêu cầu nào',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Nhấn nút bên dưới để gửi yêu cầu sửa chữa.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DesignTokens.neutralVariant,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  88,
                ),
                itemCount: provider.requests.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = provider.requests[index];
                  return _RequestCard(
                    request: item,
                    subtitle: dateFmt.format(item.createdAt),
                    onTap: () => context.push(
                      AppRoutes.requestDetail.replaceFirst(':id', item.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.subtitle,
    required this.onTap,
  });

  final RequestModel request;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignTokens.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
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
                      request.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  RequestStatusChip(status: request.status),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                request.category.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: DesignTokens.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
