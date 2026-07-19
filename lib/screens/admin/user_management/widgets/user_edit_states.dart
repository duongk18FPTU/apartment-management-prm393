import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../widgets/loading_indicator.dart';

class UserEditSkeleton extends StatelessWidget {
  const UserEditSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: List.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: LoadingIndicator.skeleton(width: double.infinity, height: 72),
        ),
      ),
    );
  }
}

class UserNotFoundState extends StatelessWidget {
  const UserNotFoundState({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MessageState(message: 'Không tìm thấy người dùng này.');
  }
}

class UserEditErrorState extends StatelessWidget {
  const UserEditErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageState(
      message: message,
      action: OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
