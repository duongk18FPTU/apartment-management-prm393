import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../announcement/announcement_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildPlaceholderTab(
        'Dashboard Thống kê',
        Icons.dashboard_customize_outlined,
        'Thống kê tổng quan căn hộ, cư dân, yêu cầu sửa chữa và doanh thu.',
      ),
      _buildPlaceholderTab(
        'Quản lý Cư dân',
        Icons.people_alt_outlined,
        'Hệ thống quản lý, phê duyệt tài khoản, căn hộ và phân quyền (Member 2).',
      ),
      const AnnouncementListScreen(),
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
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Cư dân',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Thông báo',
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon, String desc) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthProvider>().logout(),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                desc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
