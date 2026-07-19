import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Purposeful empty and error states for the user management list.
class UserEmptyState extends StatelessWidget {
  const UserEmptyState({
    super.key,
    required this.hasFilters,
    required this.onReset,
  });

  final bool hasFilters;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasFilters
                  ? 'Không tìm thấy người dùng phù hợp'
                  : 'Chưa có người dùng',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'Thử thay đổi từ khóa hoặc bộ lọc để xem thêm kết quả.'
                  : 'Tạo hồ sơ người dùng đầu tiên để bắt đầu quản lý cư dân và nhân viên.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: onReset, child: const Text('Xóa bộ lọc')),
            ],
          ],
        ),
      ),
    );
  }
}

class UserListErrorState extends StatelessWidget {
  const UserListErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không thể tải người dùng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
