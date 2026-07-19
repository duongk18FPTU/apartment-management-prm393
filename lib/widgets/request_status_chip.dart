import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/request_model.dart';

/// Small status pill for maintenance requests.
class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      RequestStatus.pending => (
        DesignTokens.secondaryContainer,
        DesignTokens.secondary,
      ),
      RequestStatus.inProgress => (
        DesignTokens.primary.withValues(alpha: 0.12),
        DesignTokens.primary,
      ),
      RequestStatus.completed => (
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
