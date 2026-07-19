import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';

/// Resident Home — temporary hub until Member 5 lands bottom navigation.
class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('My Home'),
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
              'Xin chào, ${user?.fullName ?? 'Cư dân'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (user?.apartmentId != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Căn hộ: ${user!.apartmentId}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _HomeActionTile(
              icon: Icons.handyman_outlined,
              title: 'Yêu cầu sửa chữa',
              subtitle: 'Gửi và theo dõi yêu cầu của bạn',
              onTap: () => context.push(AppRoutes.requestList),
            ),
            const SizedBox(height: AppSpacing.sm),
            _HomeActionTile(
              icon: Icons.feedback_outlined,
              title: 'Khiếu nại / Góp ý',
              subtitle: 'Gửi và theo dõi phản hồi từ Ban quản lý',
              onTap: () => context.push(AppRoutes.complaintList),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionTile extends StatelessWidget {
  const _HomeActionTile({
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
              Icon(icon, size: 32, color: DesignTokens.secondary),
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
