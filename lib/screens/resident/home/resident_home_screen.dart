import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/bill_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/vietnamese_formatters.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyBills();
    });
  }

  void _fetchMyBills() {
    final userModel = context.read<AuthProvider>().userModel;
    if (userModel?.apartmentId != null) {
      context.read<BillProvider>().loadBills(
        apartmentId: userModel!.apartmentId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final billProvider = context.watch<BillProvider>();
    final allBills = billProvider.bills;

    // Filter unpaid/overdue bills
    final unpaidBills = allBills
        .where((b) => b.status == 'unpaid' || b.status == 'overdue')
        .toList();
    final unpaidSum = unpaidBills.fold(0.0, (sum, b) => sum + b.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF75777D),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'CĂN HỘ',
                            style: TextStyle(
                              color: Color(0xFF75777D),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            user?.apartmentId != null
                                ? 'Phòng ${user!.apartmentId}'
                                : 'Chưa thiết lập',
                            style: const TextStyle(
                              color: Color(0xFF091426),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Color(0xFFBA1A1A),
                        ),
                        tooltip: 'Đăng xuất',
                        onPressed: () => context.read<AuthProvider>().logout(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchMyBills();
          },
          color: const Color(0xFF091426),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                Text(
                  'Xin chào, ${user?.fullName ?? 'Cư dân'}',
                  style: const TextStyle(
                    color: Color(0xFF091426),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Chào mừng bạn quay trở lại ngôi nhà của mình.',
                  style: TextStyle(color: Color(0xFF75777D), fontSize: 14),
                ),

                const SizedBox(height: 24),

                // Unpaid Bill Card Banner
                if (unpaidSum > 0)
                  Container(
                    padding: const EdgeInsets.all(20),
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
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                ),
                              ),
                              child: const Text(
                                'Chưa thanh toán',
                                style: TextStyle(
                                  color: Color(0xFFD97706),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kỳ tháng ${unpaidBills.first.billingMonth}',
                              style: const TextStyle(
                                color: Color(0xFF75777D),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TỔNG TIỀN CẦN THANH TOÁN',
                                  style: TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      VietnameseFormatters.currency
                                          .format(unpaidSum)
                                          .replaceAll(' ₫', ''),
                                      style: const TextStyle(
                                        color: Color(0xFF091426),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'VND',
                                      style: TextStyle(
                                        color: Color(0xFF75777D),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .push(
                                      '/resident/bills/${unpaidBills.first.billId}/pay',
                                    )
                                    .then((_) => _fetchMyBills());
                              },
                              icon: const Icon(
                                Icons.payments_rounded,
                                size: 16,
                              ),
                              label: const Text('Thanh toán ngay'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF091426),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD1FAE5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.celebration_rounded,
                            color: Color(0xFF059669),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tuyệt vời!',
                                style: TextStyle(
                                  color: Color(0xFF065F46),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tất cả hóa đơn căn hộ đã được thanh toán.',
                                style: TextStyle(
                                  color: Color(0xFF047857),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Quick Actions Section
                const Text(
                  'TIỆN ÍCH NHANH',
                  style: TextStyle(
                    color: Color(0xFF75777D),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    _buildQuickActionItem(
                      icon: Icons.handyman_outlined,
                      label: 'Sửa chữa',
                      onTap: () => context.push(AppRoutes.requestList),
                    ),
                    _buildQuickActionItem(
                      icon: Icons.person_add_alt_1_outlined,
                      label: 'Đăng ký khách',
                      onTap: () =>
                          context.push(AppRoutes.residentVisitorRegister),
                    ),
                    _buildQuickActionItem(
                      icon: Icons.forum_outlined,
                      label: 'Góp ý',
                      onTap: () => context.push(AppRoutes.complaintList),
                    ),
                    _buildQuickActionItem(
                      icon: Icons.history_edu_outlined,
                      label: 'Lịch sử hóa đơn',
                      onTap: () =>
                          context.push(AppRoutes.residentPaymentHistory),
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

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x02091426),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF091426), size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF091426),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
