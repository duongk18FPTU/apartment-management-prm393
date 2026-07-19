import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/complaint_model.dart';

class ComplaintStatusChip extends StatelessWidget {
  const ComplaintStatusChip({super.key, required this.status});

  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      ComplaintStatus.submitted => (
        DesignTokens.secondaryContainer,
        DesignTokens.secondary,
      ),
      ComplaintStatus.inReview => (
        DesignTokens.primary.withValues(alpha: 0.12),
        DesignTokens.primary,
      ),
      ComplaintStatus.resolved => (
        DesignTokens.tertiaryContainer,
        DesignTokens.tertiary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
