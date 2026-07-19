import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/request_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/vietnamese_formatters.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/request_status_chip.dart';

/// Shared detail screen for Resident and Staff.
class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestProvider>().loadRequestDetail(widget.requestId);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(RequestStatus status) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<RequestProvider>();
    final ok = await provider.updateStatus(
      requestId: widget.requestId,
      status: status,
      staffId: auth.userModel?.uid,
      resolutionNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã cập nhật: ${status.label}'
              : (provider.errorMessage ?? 'Cập nhật thất bại'),
        ),
        backgroundColor: ok ? DesignTokens.tertiary : DesignTokens.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final role = context.watch<AuthProvider>().role;
    final isStaff = role == UserRole.staff || role == UserRole.admin;
    final request = provider.selected;
    final dateFmt = VietnameseFormatters.dateTime;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Chi tiết yêu cầu')),
      body: provider.isLoading && request == null
          ? const Center(child: LoadingIndicator.circular())
          : request == null
          ? Center(
              child: Text(
                provider.errorMessage ?? 'Không tìm thấy yêu cầu',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    RequestStatusChip(status: request.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _MetaRow(label: 'Loại', value: request.category.label),
                _MetaRow(label: 'Căn hộ', value: request.apartmentId),
                _MetaRow(
                  label: 'Ngày gửi',
                  value: dateFmt.format(request.createdAt),
                ),
                if (request.assignedStaffId != null)
                  _MetaRow(
                    label: 'NV phụ trách',
                    value: request.assignedStaffId!,
                  ),
                const SizedBox(height: AppSpacing.md),
                Text('Mô tả', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  request.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (request.resolutionNote != null &&
                    request.resolutionNote!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Ghi chú xử lý',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    request.resolutionNote!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (request.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Ảnh đính kèm',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: request.imageUrls.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: CachedNetworkImage(
                            imageUrl: request.imageUrls[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              width: 120,
                              height: 120,
                              color: DesignTokens.surfaceVariant,
                              child: const Center(
                                child: LoadingIndicator.circular(size: 24),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              width: 120,
                              height: 120,
                              color: DesignTokens.surfaceVariant,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (isStaff && request.status != RequestStatus.completed) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Cập nhật xử lý (Staff)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomTextField(
                    label: 'Ghi chú giải quyết',
                    hint: 'Mô tả cách xử lý...',
                    controller: _noteController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (request.status == RequestStatus.pending)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSubmitting
                            ? null
                            : () => _updateStatus(RequestStatus.inProgress),
                        child: provider.isSubmitting
                            ? const LoadingIndicator.circular(size: 24)
                            : const Text('Nhận xử lý'),
                      ),
                    ),
                  if (request.status == RequestStatus.inProgress) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isSubmitting
                            ? null
                            : () => _updateStatus(RequestStatus.completed),
                        child: provider.isSubmitting
                            ? const LoadingIndicator.circular(size: 24)
                            : const Text('Đánh dấu hoàn thành'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.neutralVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
