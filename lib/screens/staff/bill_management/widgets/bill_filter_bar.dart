import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../widgets/status_badge.dart';

class BillFilterBar extends StatelessWidget {
  final String? selectedStatus;
  final String? selectedMonth;
  final List<String> statuses;
  final List<String> months;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onMonthChanged;

  const BillFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedMonth,
    required this.statuses,
    required this.months,
    required this.onStatusChanged,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: DesignTokens.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DropdownButton<String>(
              value: selectedStatus,
              hint: Text('Trạng thái', style: textTheme.bodyMedium),
              onChanged: onStatusChanged,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả trạng thái'),
                ),
                ...statuses.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(
                      BillStatus.values
                          .firstWhere((e) => e.name == status)
                          .label,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            DropdownButton<String>(
              value: selectedMonth,
              hint: Text('Tháng', style: textTheme.bodyMedium),
              onChanged: onMonthChanged,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả các tháng'),
                ),
                ...months.map(
                  (m) => DropdownMenuItem(value: m, child: Text('Tháng $m')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
