import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Màn hình trống (Empty State) tối giản và sang trọng.
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    this.title = 'Không có dữ liệu',
    this.message = 'Không tìm thấy thông tin nào phù hợp.',
    this.icon = Icons.folder_open_outlined,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon chứa trong vòng tròn xám nhạt tinh tế
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: DesignTokens.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: DesignTokens.neutralVariant),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tiêu đề
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: DesignTokens.onBackground,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Mô tả chi tiết
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
                textAlign: TextAlign.center,
              ),

              // Nút hành động bổ sung (nếu có)
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: onActionPressed,
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
