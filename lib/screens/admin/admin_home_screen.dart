import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';
import '../profile/profile_screen.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final List<Widget> tabs = [
      _buildDashboardTab(textTheme),
      const ApartmentListScreen(),
      const ResidentListScreen(),
      const UserProfileScreen(),
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
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(TextTheme textTheme) {
    final dash = context.watch<DashboardProvider>();
    final stats = dash.stats;

    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: dash.isLoading ? null : () => dash.load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: dash.load,
        color: DesignTokens.secondary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                'Tổng quan vận hành tòa nhà',
                style: textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (dash.isLoading &&
                  stats.apartmentCount == 0 &&
                  dash.errorMessage == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: LoadingIndicator.circular()),
                )
              else ...[
                if (dash.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      dash.errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.error,
                      ),
                    ),
                  ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.35,
                  children: [
                    _StatCard(
                      label: 'Căn hộ',
                      value: '${stats.apartmentCount}',
                      icon: Icons.apartment_rounded,
                      color: DesignTokens.tertiary,
                    ),
                    _StatCard(
                      label: 'Cư dân',
                      value: '${stats.residentCount}',
                      icon: Icons.people_alt_rounded,
                      color: DesignTokens.secondary,
                    ),
                    _StatCard(
                      label: 'Request chờ',
                      value: '${stats.pendingRequests}',
                      icon: Icons.build_rounded,
                      color: const Color(0xFF3B82F6),
                    ),
                    _StatCard(
                      label: 'Hóa đơn unpaid',
                      value: '${stats.unpaidBills}',
                      icon: Icons.receipt_long_rounded,
                      color: DesignTokens.error,
                    ),
                    _StatCard(
                      label: 'Khách trong tòa',
                      value: '${stats.visitorsInside}',
                      icon: Icons.badge_rounded,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
                _buildBentoCard(
                  Icons.campaign_outlined,
                  'Thông báo',
                  'Tạo và quản lý thông báo chung.',
                  DesignTokens.secondary,
                  () => context.push(AppRoutes.announcementList),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Truy cập nhanh',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                  _buildBentoCard(
                    Icons.badge_outlined,
                    'Khách thăm',
                    'Danh sách khách & check-in/out.',
                    DesignTokens.primary,
                    () => context.push(AppRoutes.staffVisitors),
                  ),
                ],
              ),
            ],
          ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: DesignTokens.neutralVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
