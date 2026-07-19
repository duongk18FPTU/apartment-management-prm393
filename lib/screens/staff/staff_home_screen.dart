import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

/// Staff Home — temporary hub until Member 5 lands bottom navigation.
class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Nhân viên'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Xin chào, ${user?.fullName ?? 'Nhân viên'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            _StaffTile(
              icon: Icons.assignment_outlined,
              title: 'Quản lý yêu cầu',
              subtitle: 'Xem và cập nhật trạng thái sửa chữa',
              onTap: () => context.push(AppRoutes.requestManage),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 2. Quản lý hóa đơn (Member 4 - Sprint 1)
            _StaffTile(
              icon: Icons.receipt_long_rounded,
              title: 'Quản lý hóa đơn',
              subtitle: 'Tạo hóa đơn, xem danh sách và thu tiền',
              onTap: () => context.push(AppRoutes.staffBills),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 3. Quản lý khiếu nại (Member 3)
            _StaffTile(
              icon: Icons.feedback_outlined,
              title: 'Quản lý khiếu nại',
              subtitle: 'Xem và phản hồi khiếu nại / góp ý',
              onTap: () => context.push(AppRoutes.complaintManage),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
          child: Row(
            children: [
              Icon(icon, size: 32, color: DesignTokens.tertiary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DesignTokens.neutralVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
