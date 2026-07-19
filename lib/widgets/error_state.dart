import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Giao diện hiển thị lỗi và hỗ trợ bấm Thử lại (Retry).
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Đã xảy ra lỗi',
    this.message =
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng của bạn.',
    this.retryLabel = 'Thử lại',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1.0 - value)),
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
              // Icon với vòng tròn đỏ nhạt sang trọng
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2), // Rose-100 cực dịu mắt
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: DesignTokens.error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tiêu đề lỗi
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: DesignTokens.onBackground,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Nội dung lỗi chi tiết
              Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
                textAlign: TextAlign.center,
              ),

              // Nút thử lại
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(retryLabel),
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
