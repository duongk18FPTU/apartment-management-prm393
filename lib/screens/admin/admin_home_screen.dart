import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

/// Admin Home — temporary hub until Member 5 lands dashboard.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
              'Admin Home',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Layout stub — Member 5 Sprint 0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.neutralVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Material(
              color: DesignTokens.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                onTap: () => context.push(AppRoutes.requestManage),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 32,
                        color: DesignTokens.secondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quản lý yêu cầu',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Xem yêu cầu sửa chữa toàn tòa',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: DesignTokens.neutralVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
