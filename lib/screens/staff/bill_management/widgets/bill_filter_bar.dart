import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../widgets/status_badge.dart';

class BillFilterBar extends StatelessWidget {
  final String? selectedStatus;
  final String? selectedMonth;
  final String? selectedApartment;
  final List<String> statuses;
  final List<String> months;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onMonthChanged;
  final ValueChanged<String>? onApartmentChanged;

  const BillFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedMonth,
    this.selectedApartment,
    required this.statuses,
    required this.months,
    required this.onStatusChanged,
    required this.onMonthChanged,
    this.onApartmentChanged,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lọc căn hộ (Apartment search/filter)
            Container(
              width: 110,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: DesignTokens.background,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: DesignTokens.neutralVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextField(
                      onChanged: onApartmentChanged,
                      style: textTheme.bodyMedium,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Phòng...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

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
