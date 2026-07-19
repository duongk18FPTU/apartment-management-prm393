import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../utils/constants.dart';
import '../profile/profile_screen.dart';
import 'bill_management/bill_list_screen.dart';
import 'complaint_management/complaint_manage_screen.dart';
import 'request_management/request_manage_screen.dart';
import 'visitor_management/visitor_list_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const RequestManageScreen(),
      const BillListScreen(),
      const VisitorListScreen(embedded: true),
      const ComplaintManageScreen(),
      const UserProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: IndexedStack(index: _selectedIndex, children: tabs),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.announcementList),
        icon: const Icon(Icons.campaign_outlined),
        label: const Text('Thông báo'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Yêu cầu',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Hóa đơn',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Khách',
          ),
          NavigationDestination(
            icon: Icon(Icons.feedback_outlined),
            selectedIcon: Icon(Icons.feedback_rounded),
            label: 'Khiếu nại',
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
}
