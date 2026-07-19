import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class UserFormError extends StatelessWidget {
  const UserFormError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer),
      ),
    );
  }
}

class UserFormSubmitButton extends StatelessWidget {
  const UserFormSubmitButton({
    super.key,
    required this.label,
    required this.isSaving,
    required this.onPressed,
  });

  final String label;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSaving ? null : onPressed,
      child: isSaving
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
                strokeWidth: 2,
              ),
            )
          : Text(label),
    );
  }
}
