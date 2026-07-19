import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const _AdminAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _WelcomeBanner(),
              const SizedBox(height: AppSpacing.xl),
              const _MetricBentoGrid(),
              const SizedBox(height: AppSpacing.xl),
              const _RecentActivitySection(),
              const SizedBox(height: AppSpacing.xl),
              const _BuildingStatusCard(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _AdminBottomNavBar(),
    );
  }
}

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AdminAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(
        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Color(0xFF091426)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu điều hướng đang được xây dựng')),
          );
        },
      ),
      title: const Text(
        'Quản lý Căn hộ',
        style: TextStyle(
          color: Color(0xFF091426),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF091426),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không có thông báo mới')),
                );
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFBA1A1A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFF091426)),
          tooltip: 'Đăng xuất',
          onPressed: () => context.read<AuthProvider>().logout(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF091426),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F091426),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Chào buổi sáng,',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Xin chào, Ban Quản Trị',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBentoGrid extends StatelessWidget {
  const _MetricBentoGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.28,
      children: [
        _MetricCard(
          icon: Icons.apartment_rounded,
          iconColor: const Color(0xFF24A375),
          badgeText: 'LIVE',
          badgeColor: const Color(0xFF85F8C4),
          badgeTextColor: const Color(0xFF002114),
          label: 'Căn hộ',
          value: '36/48 Đã thuê',
          onTap: () => context.push(AppRoutes.apartmentList),
        ),
        _MetricCard(
          icon: Icons.people_rounded,
          iconColor: const Color(0xFF091426),
          label: 'Cư dân',
          value: '124 Người',
          onTap: () => context.push(AppRoutes.userList),
        ),
        _MetricCard(
          icon: Icons.build_rounded,
          iconColor: const Color(0xFF904D00),
          label: 'Yêu cầu sửa chữa',
          value: '5 Chờ xử lý',
          onTap: () => context.push(AppRoutes.requestManage),
          borderColor: const Color(0xFFFE932C),
        ),
        _MetricCard(
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFFBA1A1A),
          label: 'Hóa đơn tháng này',
          value: '12 Chưa thanh toán',
          onTap: () => context.push(AppRoutes.staffBills),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.borderColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor ?? const Color(0xFFE2E8F0),
          width: borderColor != null ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        badgeText!,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF45474C),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hoạt động gần đây',
              style: TextStyle(
                color: Color(0xFF091426),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lịch sử đầy đủ đang được xây dựng'),
                  ),
                );
              },
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActivityItem(
          icon: Icons.engineering_rounded,
          iconBgColor: const Color(0xFFFFB77D),
          iconColor: const Color(0xFF6E3900),
          title: 'Căn hộ 301 gửi yêu cầu sửa chữa',
          subtitle: 'Vòi nước bị rò rỉ • 10 phút trước',
          onTap: () => context.push(AppRoutes.requestManage),
        ),
        const SizedBox(height: 8),
        _ActivityItem(
          icon: Icons.payments_rounded,
          iconBgColor: const Color(0xFF68DBA9),
          iconColor: const Color(0xFF002114),
          title: 'Đã nhận thanh toán từ phòng 501',
          subtitle: 'Tiền thuê tháng 10 • 1 giờ trước',
          onTap: () => context.push(AppRoutes.staffBills),
        ),
        const SizedBox(height: 8),
        _ActivityItem(
          icon: Icons.person_add_rounded,
          iconBgColor: const Color(0xFFD8E3FB),
          iconColor: const Color(0xFF111C2d),
          title: 'Cư dân mới tại P.204',
          subtitle: 'Đã hoàn tất hợp đồng • 3 giờ trước',
          onTap: () => context.push(AppRoutes.userList),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF091426),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF45474C),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF45474C),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildingStatusCard extends StatelessWidget {
  const _BuildingStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDxCM38JRNOjlxUZqjRNEbO3yxak4gi2SVBJIv9RLnzuX28_hdc-YH6cHIhsn9ZWCqdq-kUOQIIcikcxp21SfqlpfNG7DY2YgkNqt4oIumKo5RXW4f4llcGbHt-jNk-1P_BapawkZ-bbNI7CVzZjpGfnFIhC4j8jQIFJZWEOTGF2Y-Ru6r9IvkfoP3YZ17ISFhsrJ62FD49pU_Ptm3-KYVh23ATzfAyRGsPx9ya5v1iU_36apOJt78nLg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xCC091426)],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        alignment: Alignment.bottomLeft,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tòa nhà A - Sunrise City',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            SizedBox(height: 2),
            Text(
              'Vận hành ổn định',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBottomNavBar extends StatelessWidget {
  const _AdminBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Dashboard (Active)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFffdcc3), // secondary-fixed
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.dashboard_rounded,
                  color: Color(0xFF6E3900),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: const Color(0xFF6E3900),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Căn hộ
          InkWell(
            onTap: () => context.push(AppRoutes.apartmentList),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.apartment_rounded,
                    color: Color(0xFF45474C),
                    size: 20,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Căn Hộ',
                    style: TextStyle(color: Color(0xFF45474C), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          // Người dùng
          InkWell(
            onTap: () => context.push(AppRoutes.userList),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_rounded, color: Color(0xFF45474C), size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Người Dùng',
                    style: TextStyle(color: Color(0xFF45474C), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
