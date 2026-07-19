import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/vietnamese_formatters.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Interactive mock visitors data
  final List<Map<String, dynamic>> _mockVisitors = [
    {
      'id': 'v1',
      'name': 'Nguyễn Văn A',
      'phone': '0901234567',
      'room': 'Phòng 702',
      'host': 'Lê Thị B',
      'expectedTime': '14:00, 20/07/2026',
      'status': 'waiting', // waiting | inside | checked_out
      'checkInTime': null,
      'checkOutTime': null,
    },
    {
      'id': 'v2',
      'name': 'Trần Thị C',
      'phone': '0912345678',
      'room': 'Phòng 105',
      'host': 'Nguyễn Văn D',
      'expectedTime': '09:30, 20/07/2026',
      'status': 'inside',
      'checkInTime': '09:35, 20/07/2026',
      'checkOutTime': null,
    },
    {
      'id': 'v3',
      'name': 'Phạm Hoàng Nam',
      'phone': '0987654321',
      'room': 'Phòng 301',
      'host': 'Vũ Hoài An',
      'expectedTime': '10:00, 20/07/2026',
      'status': 'checked_out',
      'checkInTime': '10:05, 20/07/2026',
      'checkOutTime': '11:30, 20/07/2026',
    },
    {
      'id': 'v4',
      'name': 'Lê Minh Quốc',
      'phone': '0933445566',
      'room': 'Phòng 404',
      'host': 'Đặng Ngọc Lan',
      'expectedTime': '16:30, 20/07/2026',
      'status': 'waiting',
      'checkInTime': null,
      'checkOutTime': null,
    },
    {
      'id': 'v5',
      'name': 'Hoàng Thanh Mai',
      'phone': '0977889900',
      'room': 'Phòng 202',
      'host': 'Phạm Quốc Bảo',
      'expectedTime': '08:00, 20/07/2026',
      'status': 'inside',
      'checkInTime': '08:05, 20/07/2026',
      'checkOutTime': null,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _insideCount =>
      _mockVisitors.where((v) => v['status'] == 'inside').length;

  int get _todayTotalCount => _mockVisitors.length;

  List<Map<String, dynamic>> get _filteredVisitors {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) return _mockVisitors;
    return _mockVisitors.where((v) {
      final name = (v['name'] as String).toLowerCase();
      final phone = (v['phone'] as String).toLowerCase();
      final room = (v['room'] as String).toLowerCase();
      return name.contains(query) ||
          phone.contains(query) ||
          room.contains(query);
    }).toList();
  }

  void _checkIn(String id) {
    setState(() {
      final idx = _mockVisitors.indexWhere((v) => v['id'] == id);
      if (idx != -1) {
        final nowFmt = VietnameseFormatters.dateTime.format(DateTime.now());
        _mockVisitors[idx]['status'] = 'inside';
        _mockVisitors[idx]['checkInTime'] = nowFmt;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã Check-in khách vào tòa nhà thành công!'),
        backgroundColor: Color(0xFF0D9488),
      ),
    );
  }

  void _checkOut(String id) {
    setState(() {
      final idx = _mockVisitors.indexWhere((v) => v['id'] == id);
      if (idx != -1) {
        final nowFmt = VietnameseFormatters.dateTime.format(DateTime.now());
        _mockVisitors[idx]['status'] = 'checked_out';
        _mockVisitors[idx]['checkOutTime'] = nowFmt;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã Check-out khách rời tòa nhà!'),
        backgroundColor: Color(0xFF1E293B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Khách viếng thăm',
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
      body: SafeArea(
        child: Column(
          children: [
            // Search and filter row
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
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm khách...',
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

            // Statistics Overview
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Đang ở trong',
                            style: TextStyle(
                              color: Color(0xFF8590A6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_insideCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.login_rounded,
                                color: Color(0x88FFFFFF),
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x051E293B),
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hôm nay',
                            style: TextStyle(
                              color: Color(0xFF75777D),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_todayTotalCount',
                                style: const TextStyle(
                                  color: Color(0xFF091426),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.groups_rounded,
                                color: Color(0xFF75777D),
                                size: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Danh sách hôm nay',
                    style: TextStyle(
                      color: Color(0xFF091426),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '20/07/2026',
                    style: TextStyle(
                      color: Color(0xFF75777D),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // List of visitors
            Expanded(
              child: _filteredVisitors.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'Không tìm thấy khách phù hợp'
                            : 'Không có khách viếng thăm hôm nay',
                        style: const TextStyle(color: Color(0xFF75777D)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: _filteredVisitors.length,
                      itemBuilder: (context, index) {
                        final visitor = _filteredVisitors[index];
                        return _buildVisitorCard(visitor);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorCard(Map<String, dynamic> visitor) {
    final status = visitor['status'] as String;
    Color badgeBg;
    Color badgeText;
    String statusLabel;

    switch (status) {
      case 'inside':
        badgeBg = const Color(0xFFE6F4EA);
        badgeText = const Color(0xFF137333);
        statusLabel = 'Đang ở trong';
        break;
      case 'checked_out':
        badgeBg = const Color(0xFFF1F3F4);
        badgeText = const Color(0xFF5F6368);
        statusLabel = 'Đã checkout';
        break;
      case 'waiting':
      default:
        badgeBg = const Color(0xFFFEF7E0);
        badgeText = const Color(0xFFB06000);
        statusLabel = 'Chờ vào';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x051E293B),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF091426),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor['name'] as String,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            color: Color(0xFF75777D),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visitor['phone'] as String,
                            style: const TextStyle(
                              color: Color(0xFF75777D),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: badgeText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          // Detail details
          Row(
            children: [
              const Icon(
                Icons.meeting_room_outlined,
                color: Color(0xFF75777D),
                size: 16,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  text: 'Căn hộ: ',
                  style: const TextStyle(
                    color: Color(0xFF75777D),
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '${visitor['host']} - ${visitor['room']}',
                      style: const TextStyle(
                        color: Color(0xFF091426),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: Color(0xFF75777D),
                size: 16,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  text: status == 'waiting'
                      ? 'Dự kiến: '
                      : status == 'inside'
                      ? 'Vào lúc: '
                      : 'Rời lúc: ',
                  style: const TextStyle(
                    color: Color(0xFF75777D),
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: status == 'waiting'
                          ? visitor['expectedTime']
                          : status == 'inside'
                          ? visitor['checkInTime']
                          : visitor['checkOutTime'],
                      style: const TextStyle(
                        color: Color(0xFF091426),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Actions
          if (status != 'checked_out') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 'waiting'
                      ? const Color(0xFF091426)
                      : Colors.white,
                  foregroundColor: status == 'waiting'
                      ? Colors.white
                      : const Color(0xFF091426),
                  elevation: 0,
                  side: status == 'inside'
                      ? const BorderSide(color: Color(0xFFE2E8F0))
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (status == 'waiting') {
                    _checkIn(visitor['id']);
                  } else if (status == 'inside') {
                    _checkOut(visitor['id']);
                  }
                },
                icon: Icon(
                  status == 'waiting'
                      ? Icons.how_to_reg_rounded
                      : Icons.logout_rounded,
                  size: 18,
                ),
                label: Text(
                  status == 'waiting' ? 'Check-in' : 'Check-out',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
