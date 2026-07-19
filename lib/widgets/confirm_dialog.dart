import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Hộp thoại xác nhận hành động quan trọng (Xác nhận/Hủy).
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Xác nhận',
    this.cancelLabel = 'Hủy',
    this.isDestructive = false,
  });

  /// Phương thức tĩnh tiện lợi để hiển thị Dialog một cách đồng bộ
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Hủy',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: DesignTokens.primary.withValues(
        alpha: 0.3,
      ), // Hiệu ứng làm tối nền nhẹ cao cấp
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: DesignTokens.surface,
      elevation: 8, // Thiết lập theo Level 2 trong DESIGN.md
      shadowColor: DesignTokens.shadowColor.withValues(alpha: 0.08),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề dialog
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: DesignTokens.onBackground,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Nội dung thông điệp
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: DesignTokens.neutralVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Hàng nút hành động tối giản bên dưới
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Nút Hủy
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.neutralVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    cancelLabel,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.neutralVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Nút Xác nhận
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDestructive
                        ? DesignTokens.error
                        : DesignTokens.primary,
                    foregroundColor: DesignTokens.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    minimumSize: const Size(120, 44),
                  ),
                  child: Text(
                    confirmLabel,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
