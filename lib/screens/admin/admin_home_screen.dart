import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import 'apartment_management/apartment_list_screen.dart';
import 'resident_management/resident_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final List<Widget> tabs = [
      _buildDashboardTab(textTheme),
      const ApartmentListScreen(),
      const ResidentListScreen(),
    ];

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize_outlined),
            selectedIcon: Icon(Icons.dashboard_customize_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment_rounded),
            label: 'Căn hộ',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Cư dân',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(TextTheme textTheme) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cổng thông tin Quản trị',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hệ thống quản lý chung cư cao cấp Haven',
              style: textTheme.bodyMedium?.copyWith(
                color: DesignTokens.neutralVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Bento Grid for Admin Quick Access
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              children: [
                _buildBentoCard(
                  Icons.people_outline_rounded,
                  'Tài khoản',
                  'Phân quyền & cấp tài khoản người dùng.',
                  DesignTokens.secondary,
                  () => context.push(AppRoutes.userList),
                ),
                _buildBentoCard(
                  Icons.apartment_rounded,
                  'Căn hộ',
                  'Xem, sửa đổi thông tin căn hộ.',
                  DesignTokens.tertiary,
                  () => setState(() => _selectedIndex = 1),
                ),
                _buildBentoCard(
                  Icons.assignment_outlined,
                  'Yêu cầu bảo trì',
                  'Xem danh sách yêu cầu bảo trì toàn tòa.',
                  const Color(0xFF3B82F6),
                  () => context.push(AppRoutes.requestManage),
                ),
                _buildBentoCard(
                  Icons.feedback_outlined,
                  'Khiếu nại',
                  'Xem phản hồi & khiếu nại của cư dân.',
                  const Color(0xFF8B5CF6),
                  () => context.push(AppRoutes.complaintManage),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard(
    IconData icon,
    String title,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
