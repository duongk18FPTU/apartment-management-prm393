import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../my_bills/my_bills_screen.dart';

class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<AuthProvider>().userModel;
    final textTheme = Theme.of(context).textTheme;

    final List<Widget> tabs = [
      _buildHomeTab(textTheme, userModel?.fullName ?? 'Cư dân'),
      const MyBillsScreen(),
      _buildPlaceholderTab(
        'Yêu cầu sửa chữa',
        Icons.build_outlined,
        'Chức năng gửi yêu cầu sửa chữa căn hộ bảo trì bảo dưỡng (Member 3).',
      ),
      _buildPlaceholderTab(
        'Thông báo tòa nhà',
        Icons.campaign_outlined,
        'Bản tin chung cư và thông báo đẩy từ Ban quản lý (Member 5).',
      ),
      _buildPlaceholderTab(
        'Cá nhân',
        Icons.person_outline_rounded,
        'Quản lý thông tin cư dân, căn hộ và thay đổi mật khẩu (Member 5).',
      ),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Hóa đơn',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Yêu cầu',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Thông báo',
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

  Widget _buildHomeTab(TextTheme textTheme, String name) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: const Text('My Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthProvider>().logout(),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: DesignTokens.secondary.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: DesignTokens.secondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào,',
                            style: textTheme.bodyMedium?.copyWith(
                              color: DesignTokens.neutralVariant,
                            ),
                          ),
                          Text(
                            name,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Dịch vụ chung cư',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Bento Grid for Resident Quick Actions
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              children: [
                _buildBentoCard(
                  Icons.receipt_long_rounded,
                  'Thanh toán',
                  'Xem & thanh toán các hóa đơn căn hộ.',
                  DesignTokens.secondary,
                  () => setState(() => _selectedIndex = 1),
                ),
                _buildBentoCard(
                  Icons.build_rounded,
                  'Sửa chữa',
                  'Gửi yêu cầu bảo trì bảo dưỡng căn hộ.',
                  DesignTokens.tertiary,
                  () => setState(() => _selectedIndex = 2),
                ),
                _buildBentoCard(
                  Icons.campaign_rounded,
                  'Thông báo',
                  'Bản tin chung cư và cảnh báo khẩn.',
                  const Color(0xFF3B82F6),
                  () => setState(() => _selectedIndex = 3),
                ),
                _buildBentoCard(
                  Icons.person_rounded,
                  'Tài khoản',
                  'Quản lý hồ sơ cư dân & thông tin phòng.',
                  const Color(0xFF8B5CF6),
                  () => setState(() => _selectedIndex = 4),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Quick Access card for Payment History
            Card(
              child: InkWell(
                borderRadius: AppRadius.borderMd,
                onTap: () => context.push(AppRoutes.residentPaymentHistory),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: DesignTokens.tertiary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: DesignTokens.tertiary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lịch Sử Giao Dịch',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Xem danh sách biên lai, lịch sử nộp tiền mặt hoặc chuyển khoản.',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: DesignTokens.neutralVariant,
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildPlaceholderTab(String title, IconData icon, String desc) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: DesignTokens.neutralVariant),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                desc,
                style: textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.neutralVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
