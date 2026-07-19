import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/complaint_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../widgets/complaint_status_chip.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_indicator.dart';

/// Shared detail — Resident views; Staff/Admin can respond.
class ComplaintDetailScreen extends StatefulWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});

  final String complaintId;

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintProvider>().loadDetail(widget.complaintId);
    });
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _markInReview() async {
    final provider = context.read<ComplaintProvider>();
    final ok = await provider.markInReview(widget.complaintId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã chuyển sang đang xem xét'
              : (provider.errorMessage ?? 'Cập nhật thất bại'),
        ),
      ),
    );
  }

  Future<void> _respond() async {
    final text = _responseController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung phản hồi')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final provider = context.read<ComplaintProvider>();
    final ok = await provider.respond(
      complaintId: widget.complaintId,
      response: text,
      respondedBy: auth.userModel?.uid ?? '',
      status: ComplaintStatus.resolved,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã gửi phản hồi'
              : (provider.errorMessage ?? 'Phản hồi thất bại'),
        ),
        backgroundColor: ok ? DesignTokens.tertiary : DesignTokens.error,
      ),
    );
    if (ok) _responseController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintProvider>();
    final role = context.watch<AuthProvider>().role;
    final canRespond = role == UserRole.staff || role == UserRole.admin;
    final item = provider.selected;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Chi tiết khiếu nại')),
      body: provider.isLoading && item == null
          ? const Center(child: LoadingIndicator.circular())
          : item == null
          ? Center(
              child: Text(provider.errorMessage ?? 'Không tìm thấy'),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Khiếu nại',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    ComplaintStatusChip(status: item.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Căn hộ: ${item.apartmentId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.neutralVariant,
                  ),
                ),
                Text(
                  'Ngày gửi: ${dateFmt.format(item.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.neutralVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Nội dung', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(item.content, style: Theme.of(context).textTheme.bodyLarge),
                if (item.response != null && item.response!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Phản hồi từ Ban quản lý',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: DesignTokens.tertiaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      item.response!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (item.respondedAt != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Phản hồi lúc: ${dateFmt.format(item.respondedAt!)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: DesignTokens.neutralVariant,
                      ),
                    ),
                  ],
                ],
                if (canRespond && item.status != ComplaintStatus.resolved) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Xử lý (Staff / Admin)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (item.status == ComplaintStatus.submitted)
                    OutlinedButton(
                      onPressed: provider.isSubmitting ? null : _markInReview,
                      child: const Text('Đánh dấu đang xem xét'),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  CustomTextField(
                    label: 'Nội dung phản hồi',
                    hint: 'Nhập phản hồi gửi cư dân...',
                    controller: _responseController,
                    maxLines: 4,
                    validator: (v) =>
                        AppValidators.validateRequired(v, fieldName: 'Phản hồi'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting ? null : _respond,
                      child: provider.isSubmitting
                          ? const LoadingIndicator.circular(size: 24)
                          : const Text('Gửi phản hồi & hoàn tất'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
