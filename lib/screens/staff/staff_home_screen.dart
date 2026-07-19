import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Staff Home Screen stub — will be fully implemented by Member 5 in Sprint 0.
///
/// Member 5 will replace this with the full layout including:
/// - Bottom navigation: Requests / Bills / Visitors / Announcements
/// - Pending request count badge
class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Staff Portal')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.badge_rounded, size: 64, color: DesignTokens.tertiary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Staff Home',
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
