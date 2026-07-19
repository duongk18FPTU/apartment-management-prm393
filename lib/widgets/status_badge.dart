import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Các trạng thái của hóa đơn trong hệ thống
enum BillStatus {
  paid,
  unpaid,
  pending,
  overdue;

  String get label {
    return switch (this) {
      BillStatus.paid => 'Đã thanh toán',
      BillStatus.unpaid => 'Chưa thanh toán',
      BillStatus.pending => 'Chờ xử lý',
      BillStatus.overdue => 'Quá hạn',
    };
  }
}

/// Badge hiển thị trạng thái hóa đơn với thiết kế tối giản, cao cấp.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  /// Factory phục vụ hiển thị trạng thái hóa đơn cụ thể
  factory StatusBadge.bill(BillStatus status) {
    final String label = status.label;
    final Color textColor;
    final Color backgroundColor;

    switch (status) {
      case BillStatus.paid:
        textColor = DesignTokens.tertiary; // Emerald Teal từ DESIGN.md
        backgroundColor = DesignTokens.tertiary.withValues(alpha: 0.12);
        break;
      case BillStatus.unpaid:
        textColor = DesignTokens.error; // Rose-600
        backgroundColor = DesignTokens.error.withValues(alpha: 0.12);
        break;
      case BillStatus.pending:
        textColor = DesignTokens.secondary; // Warm Amber
        backgroundColor = DesignTokens.secondary.withValues(alpha: 0.12);
        break;
      case BillStatus.overdue:
        textColor = const Color(
          0xFF991B1B,
        ); // Crimson Red sâu cho trạng thái quá hạn nặng
        backgroundColor = const Color(0xFFFEE2E2); // Rose-100
        break;
    }

    return StatusBadge(
      label: label,
      textColor: textColor,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderSm, // 8px theo cấu trúc tag/badge
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Chấm tròn nhỏ thể hiện trạng thái cao cấp
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
