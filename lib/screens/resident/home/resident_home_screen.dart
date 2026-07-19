import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Resident Home Screen stub — will be fully implemented by Member 5 in Sprint 0.
///
/// Member 5 will replace this with the full layout including:
/// - Bottom navigation: Home / Bills / Requests / Announcements / Profile
/// - Welcome banner with resident name and apartment number
class ResidentHomeScreen extends StatelessWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('My Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, size: 64, color: DesignTokens.secondary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Resident Home',
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
