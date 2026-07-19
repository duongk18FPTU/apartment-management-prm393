import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/request_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/request_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/vietnamese_formatters.dart';
import '../../../widgets/loading_indicator.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _noteController = TextEditingController();
  RequestStatus? _selectedStatus;

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

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;
    final auth = context.read<AuthProvider>();
    final provider = context.read<RequestProvider>();
    final ok = await provider.updateStatus(
      requestId: widget.requestId,
      status: _selectedStatus!,
      staffId: auth.userModel?.uid,
      resolutionNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã cập nhật trạng thái thành công!'
              : (provider.errorMessage ?? 'Cập nhật thất bại'),
        ),
        backgroundColor: ok ? const Color(0xFF0D9488) : const Color(0xFFBA1A1A),
      ),
    );
    if (ok) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final role = context.watch<AuthProvider>().role;
    final isStaff = role == UserRole.staff || role == UserRole.admin;
    final request = provider.selected;
    final dateFmt = VietnameseFormatters.date;

    if (request != null) {
      _selectedStatus ??= request.status;
      if (_noteController.text.isEmpty && request.resolutionNote != null) {
        _noteController.text = request.resolutionNote!;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF091426)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chi tiết yêu cầu',
          style: TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE2E8F0),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF75777D),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading && request == null
          ? const Center(child: LoadingIndicator.circular())
          : request == null
          ? Center(
              child: Text(
                provider.errorMessage ?? 'Không tìm thấy yêu cầu',
                style: const TextStyle(color: Color(0xFF75777D)),
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 100.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Request Identity Card
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x05091426),
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusBadge(request.status),
                                Text(
                                  dateFmt.format(request.createdAt),
                                  style: const TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              request.title,
                              style: const TextStyle(
                                color: Color(0xFF091426),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.meeting_room_outlined,
                                  color: Color(0xFF75777D),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Căn hộ: Phòng ${request.apartmentId}',
                                  style: const TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFF1F5F9), height: 1),
                            const SizedBox(height: 16),
                            const Text(
                              'MÔ TẢ CHI TIẾT',
                              style: TextStyle(
                                color: Color(0xFF091426),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.description,
                              style: const TextStyle(
                                color: Color(0xFF45474C),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Image Attachment Section
                      if (request.imageUrls.isNotEmpty) ...[
                        const Text(
                          'Hình ảnh đính kèm',
                          style: TextStyle(
                            color: Color(0xFF091426),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.34,
                              child: CachedNetworkImage(
                                imageUrl: request.imageUrls.first,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: Color(0xFF75777D),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Resolution note display for resident / or if completed
                      if (!isStaff &&
                          request.resolutionNote != null &&
                          request.resolutionNote!.isNotEmpty) ...[
                        const Text(
                          'Ghi chú giải quyết của BQL',
                          style: TextStyle(
                            color: Color(0xFF091426),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            request.resolutionNote!,
                            style: const TextStyle(
                              color: Color(0xFF45474C),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Update Status Section (Staff edit fields)
                      if (isStaff &&
                          request.status != RequestStatus.completed) ...[
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x05091426),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.sync_alt_rounded,
                                    color: Color(0xFF091426),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Cập nhật trạng thái',
                                    style: TextStyle(
                                      color: Color(0xFF091426),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Trạng thái hiện tại',
                                style: TextStyle(
                                  color: Color(0xFF75777D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<RequestStatus>(
                                    value: _selectedStatus,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    items: RequestStatus.values.map((status) {
                                      return DropdownMenuItem<RequestStatus>(
                                        value: status,
                                        child: Text(
                                          status.label,
                                          style: const TextStyle(
                                            color: Color(0xFF091426),
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedStatus = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Ghi chú xử lý (Nhân viên)',
                                style: TextStyle(
                                  color: Color(0xFF75777D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _noteController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Nhập ghi chú hoặc kết quả sửa chữa...',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF091426),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Fixed Bottom Action Bar
                if (isStaff && request.status != RequestStatus.completed)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        16.0,
                        20.0,
                        24.0,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        ),
                      ),
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: provider.isSubmitting
                              ? null
                              : _updateStatus,
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text('Cập nhật trạng thái'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF091426),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    String statusLabel;
    Color statusBg;
    Color statusText;

    switch (status) {
      case RequestStatus.pending:
        statusLabel = 'Mới nhận';
        statusBg = const Color(0xFFFEF7E0);
        statusText = const Color(0xFFB06000);
        break;
      case RequestStatus.inProgress:
        statusLabel = 'Đang xử lý';
        statusBg = const Color(0xFFE8F0FE);
        statusText = const Color(0xFF1A73E8);
        break;
      case RequestStatus.completed:
        statusLabel = 'Hoàn thành';
        statusBg = const Color(0xFFE6F4EA);
        statusText = const Color(0xFF137333);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          color: statusText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
