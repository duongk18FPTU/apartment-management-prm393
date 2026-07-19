import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../models/bill_model.dart';
import '../../../../utils/vietnamese_formatters.dart';
import '../../../../widgets/status_badge.dart';

class BillCard extends StatelessWidget {
  final BillModel bill;
  final VoidCallback onTap;

  const BillCard({super.key, required this.bill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phòng ${bill.apartmentId}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StatusBadge.bill(
                    BillStatus.values.firstWhere((e) => e.name == bill.status),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.type.label,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Tháng ${VietnameseFormatters.billingMonth(bill.billingMonth)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    VietnameseFormatters.currency.format(bill.amount),
                    style: textTheme.titleLarge?.copyWith(
                      color: DesignTokens.onBackground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
