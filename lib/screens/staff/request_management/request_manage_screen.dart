import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/request_model.dart';
import '../../../providers/request_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/vietnamese_formatters.dart';

class RequestManageScreen extends StatefulWidget {
  const RequestManageScreen({super.key});

  @override
  State<RequestManageScreen> createState() => _RequestManageScreenState();
}

class _RequestManageScreenState extends State<RequestManageScreen> {
  RequestStatus? _selectedStatus = RequestStatus.pending;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Chờ xử lý', 'status': RequestStatus.pending},
    {'label': 'Đang sửa', 'status': RequestStatus.inProgress},
    {'label': 'Đã hoàn thành', 'status': RequestStatus.completed},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await context.read<RequestProvider>().loadAllRequests(
      status: _selectedStatus,
    );
  }

  Future<void> _onTabChanged(RequestStatus? status) async {
    setState(() => _selectedStatus = status);
    await context.read<RequestProvider>().loadAllRequests(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final allRequests = provider.requests;

    // Client-side search filtering
    final filteredRequests = allRequests.where((req) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      return req.title.toLowerCase().contains(q) ||
          req.description.toLowerCase().contains(q) ||
          req.apartmentId.toLowerCase().contains(q);
    }).toList();

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
          'Yêu cầu sửa chữa',
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
                Icons.engineering_rounded,
                color: Color(0xFF75777D),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm phòng, nội dung...',
                          hintStyle: TextStyle(
                            color: Color(0xFF75777D),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF75777D),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: Color(0xFF091426),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Tab Navigation
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedStatus == tab['status'];
                  return GestureDetector(
                    onTap: () => _onTabChanged(tab['status']),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? const Color(0xFF091426)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tab['label']!,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF091426)
                              : const Color(0xFF75777D),
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 1),

            // Request List Area
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                color: const Color(0xFF091426),
                child: provider.isLoading && allRequests.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null && allRequests.isEmpty
                    ? _buildErrorState(provider.errorMessage!)
                    : filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          final req = filteredRequests[index];
                          return _buildRequestCard(req);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(RequestModel req) {
    Color categoryBg;
    Color categoryColor;
    IconData categoryIcon;

    switch (req.category) {
      case RequestCategory.electrical:
        categoryBg = const Color(0xFFFEF7E0);
        categoryColor = const Color(0xFFB06000);
        categoryIcon = Icons.lightbulb_outline_rounded;
        break;
      case RequestCategory.plumbing:
        categoryBg = const Color(0xFFE8F0FE);
        categoryColor = const Color(0xFF1A73E8);
        categoryIcon = Icons.water_drop_outlined;
        break;
      case RequestCategory.general:
        categoryBg = const Color(0xFFF1F3F4);
        categoryColor = const Color(0xFF5F6368);
        categoryIcon = Icons.build_outlined;
        break;
    }

    String statusLabel;
    Color statusBg;
    Color statusText;

    switch (req.status) {
      case RequestStatus.pending:
        statusLabel = 'Chờ xử lý';
        statusBg = const Color(0xFFFEF7E0);
        statusText = const Color(0xFFB06000);
        break;
      case RequestStatus.inProgress:
        statusLabel = 'Đang sửa';
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
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05091426),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context
              .push(AppRoutes.requestDetail.replaceFirst(':id', req.id))
              .then((_) => _load()),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Category and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: categoryBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            categoryIcon,
                            color: categoryColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          req.category.label,
                          style: const TextStyle(
                            color: Color(0xFF091426),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title and description
                Text(
                  req.title,
                  style: const TextStyle(
                    color: Color(0xFF091426),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  req.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF75777D),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 12),

                // Room & Date Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.meeting_room_outlined,
                              color: Color(0xFF75777D),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Phòng ${req.apartmentId}',
                              style: const TextStyle(
                                color: Color(0xFF75777D),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF75777D),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              VietnameseFormatters.date.format(req.createdAt),
                              style: const TextStyle(
                                color: Color(0xFF75777D),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFE2E8F0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF75777D)),
          const SizedBox(height: 12),
          const Text(
            'Không có yêu cầu sửa chữa nào',
            style: TextStyle(color: Color(0xFF75777D), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFBA1A1A)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091426),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
