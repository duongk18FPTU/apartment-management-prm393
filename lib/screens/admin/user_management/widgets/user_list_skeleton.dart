import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../widgets/loading_indicator.dart';

/// Skeleton rows shaped like the final user list content.
class UserListSkeleton extends StatelessWidget {
  const UserListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const LoadingIndicator.skeleton(
        width: double.infinity,
        height: 116,
        borderRadius: AppRadius.borderMd,
      ),
    );
  }
}
