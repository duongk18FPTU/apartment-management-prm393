import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Admin Home Screen stub — will be fully implemented by Member 5 in Sprint 0.
///
/// Member 5 will replace this with the full layout including:
/// - Bottom navigation bar (or NavigationRail for tablet)
/// - Dashboard statistics section
/// - Quick-action tiles
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                size: 64,
                color: DesignTokens.secondary,
              ),
              const SizedBox(height: AppSpacing.md),
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
            ],
          ),
        ),
      ),
    );
  }
}
