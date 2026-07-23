import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/notification_model.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/loading_indicator.dart';

/// All roles — list of building announcements.
class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadAnnouncements();
    });
  }

  Future<void> _reload() =>
      context.read<AnnouncementProvider>().loadAnnouncements();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();
    final role = context.watch<AuthProvider>().role;
    final canCreate = role == UserRole.admin || role == UserRole.staff;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Thông báo')),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.announcementCreate),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tạo thông báo'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _reload,
        color: DesignTokens.secondary,
        child: provider.isLoading && provider.items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  LoadingIndicator.circular(),
                ],
              )
            : provider.errorMessage != null && provider.items.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: ErrorState(
                      message: provider.errorMessage!,
                      onRetry: _reload,
                    ),
                  ),
                ],
              )
            : provider.items.isEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: const EmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'Chưa có thông báo',
                      message: 'Các thông báo chung của tòa sẽ hiện tại đây.',
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  canCreate ? 88 : AppSpacing.md,
                ),
                itemCount: provider.items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final item = provider.items[index];
                  return Material(
                    color: DesignTokens.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => context.push(
                        AppRoutes.announcementDetail.replaceFirst(
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
                                Icon(
                                  Icons.campaign_rounded,
                                  color: DesignTokens.secondary,
                                  size: 22,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Chip(
                                  label: Text(
                                    AnnouncementType.fromValue(item.type).label,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              item.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: DesignTokens.neutralVariant,
                                  ),
                            ),
                            if (item.createdAt != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                dateFmt.format(item.createdAt!),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: DesignTokens.neutralVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
