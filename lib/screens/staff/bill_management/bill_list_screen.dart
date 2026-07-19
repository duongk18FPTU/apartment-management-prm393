import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../providers/bill_provider.dart';
import '../../../utils/vietnamese_formatters.dart';
import 'widgets/bill_card.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  String? _selectedStatus;
  String? _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String?>> _filterChips = [
    {'label': 'Tất cả', 'status': null},
    {'label': 'Chưa thanh toán', 'status': 'unpaid'},
    {'label': 'Chờ phê duyệt', 'status': 'pending'},
    {'label': 'Đã thanh toán', 'status': 'paid'},
    {'label': 'Quá hạn', 'status': 'overdue'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBills();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchBills() {
    context.read<BillProvider>().loadBills(status: _selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final allBills = billProvider.bills;

    // Filter by search query (room/apartment number or bill ID)
    final filteredBills = allBills.where((bill) {
      final q = _searchQuery?.toLowerCase().trim() ?? '';
      if (q.isEmpty) return true;
      return bill.apartmentId.toLowerCase().contains(q) ||
          bill.billId.toLowerCase().contains(q) ||
          bill.type.label.toLowerCase().contains(q);
    }).toList();

    // Calculate dynamic stats
    final unpaidSum = allBills
        .where((b) => b.status == 'unpaid' || b.status == 'overdue')
        .fold(0.0, (sum, b) => sum + b.amount);

    final pendingCount = allBills.where((b) => b.status == 'pending').length;

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
          'Quản lý hóa đơn',
          style: TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: Color(0xFF091426),
              size: 28,
            ),
            onPressed: () async {
              await context.push('/staff/bills/create');
              _fetchBills();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF091426),
        foregroundColor: Colors.white,
        onPressed: () async {
          await context.push('/staff/bills/create');
          _fetchBills();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm phòng, mã hóa đơn...',
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

            // Horizontal Filter Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: _filterChips.length,
                itemBuilder: (context, index) {
                  final chip = _filterChips[index];
                  final isSelected = _selectedStatus == chip['status'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 4.0,
                    ),
                    child: ChoiceChip(
                      label: Text(chip['label']!),
                      selected: isSelected,
                      selectedColor: const Color(0xFF091426),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF45474C),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF091426)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedStatus = chip['status'];
                          });
                          _fetchBills();
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            // Asymmetric Overview Cards
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng chưa thu',
                            style: TextStyle(
                              color: Color(0xFF8590A6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            VietnameseFormatters.currency.format(unpaidSum),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chờ phê duyệt',
                            style: TextStyle(
                              color: Color(0xFF75777D),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: Color(0xFF091426),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (pendingCount > 0)
                                const Icon(
                                  Icons.pending_actions_rounded,
                                  color: Color(0xFFFE932C),
                                  size: 24,
                                )
                              else
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Color(0xFF0D9488),
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

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Danh sách hóa đơn',
                    style: TextStyle(
                      color: Color(0xFF091426),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tổng số: ${filteredBills.length}',
                    style: const TextStyle(
                      color: Color(0xFF75777D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // List of Bills
            Expanded(child: _buildBillsList(billProvider, filteredBills)),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsList(BillProvider provider, List<dynamic> filteredList) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF091426)),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return ErrorState(message: provider.errorMessage!, onRetry: _fetchBills);
    }

    if (filteredList.isEmpty) {
      return EmptyState(
        title: 'Không tìm thấy hóa đơn nào',
        message: 'Hãy thử đổi bộ lọc hoặc gõ phòng cần tìm kiếm.',
        icon: Icons.receipt_long_outlined,
        actionLabel: 'Tải lại dữ liệu',
        onActionPressed: _fetchBills,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final bill = filteredList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: BillCard(
            bill: bill,
            onTap: () async {
              await context.push('/staff/bills/${bill.billId}');
              _fetchBills();
            },
          ),
        );
      },
    );
  }
}
