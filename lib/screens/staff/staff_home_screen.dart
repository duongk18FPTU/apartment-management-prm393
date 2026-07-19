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
        title: const Text('Staff Portal'),
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
            Material(
              color: DesignTokens.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                onTap: () => context.push(AppRoutes.complaintManage),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.feedback_outlined,
                        size: 32,
                        color: DesignTokens.tertiary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quản lý khiếu nại',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Xem và phản hồi khiếu nại / góp ý',
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
