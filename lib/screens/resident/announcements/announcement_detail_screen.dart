import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../providers/announcement_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/loading_indicator.dart';

/// Announcement detail — all roles; Admin/Staff can edit/delete.
class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  final String announcementId;

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadDetail(widget.announcementId);
    });
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Xóa thông báo?',
      message: 'Thao tác này không thể hoàn tác.',
      confirmLabel: 'Xóa',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<AnnouncementProvider>();
    final ok = await provider.deleteAnnouncement(widget.announcementId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa thông báo')));
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Xóa thất bại'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();
    final role = context.watch<AuthProvider>().role;
    final canManage = role == UserRole.admin || role == UserRole.staff;
    final item = provider.selected;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
        actions: [
          if (canManage && item != null) ...[
            IconButton(
              tooltip: 'Sửa',
              onPressed: () => context.push(
                '${AppRoutes.announcementCreate}?id=${item.id}',
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Xóa',
              onPressed: provider.isSubmitting ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ],
      ),
      body: provider.isLoading && item == null
          ? const Center(child: LoadingIndicator.circular())
          : item == null
          ? Center(child: Text(provider.errorMessage ?? 'Không tìm thấy'))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (item.createdAt != null)
                  Text(
                    dateFmt.format(item.createdAt!),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: DesignTokens.neutralVariant,
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (item.targetRoles.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: item.targetRoles
                        .map(
                          (r) => Chip(
                            label: Text(r),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
    );
  }
}
