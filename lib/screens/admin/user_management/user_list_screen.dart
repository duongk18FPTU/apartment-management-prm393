import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/constants.dart';
import 'widgets/user_feedback_states.dart';
import 'widgets/user_filter_bar.dart';
import 'widgets/user_inline_error.dart';
import 'widgets/user_list_item.dart';
import 'widgets/user_list_skeleton.dart';

/// Admin-only searchable and filterable user management list.
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserProvider>().listenToUsers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF091426)),
          onPressed: () {
            context.go(AppRoutes.adminHome);
          },
        ),
        title: const Text(
          'Quản lý tài khoản',
          style: TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF091426),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
            ),
            onPressed: () => context.push(AppRoutes.userCreate),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFE932C),
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.userCreate),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Thêm người dùng'),
      ),
      bottomNavigationBar: const _BottomNavBar(),
      body: Column(
        children: [
          UserFilterBar(
            searchController: _searchController,
            roleFilter: provider.roleFilter,
            statusFilter: provider.statusFilter,
            onSearchChanged: provider.setSearchQuery,
            onRoleChanged: provider.setRoleFilter,
            onStatusChanged: provider.setStatusFilter,
          ),
          if (provider.errorMessage != null && provider.users.isNotEmpty)
            UserInlineError(message: provider.errorMessage!),
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }

  Widget _buildContent(UserProvider provider) {
    if (provider.isLoading) return const UserListSkeleton();
    if (provider.errorMessage != null && provider.users.isEmpty) {
      return UserListErrorState(onRetry: provider.refreshUsers);
    }
    if (provider.filteredUsers.isEmpty) {
      return UserEmptyState(
        hasFilters: provider.hasActiveFilters,
        onReset: () {
          _searchController.clear();
          provider.clearFilters();
        },
      );
    }
    return RefreshIndicator(
      onRefresh: () async => provider.refreshUsers(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl * 3,
        ),
        itemCount: provider.filteredUsers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final user = provider.filteredUsers[index];
          return UserListItem(
            user: user,
            onTap: () => context.push('/admin/users/${user.uid}/edit'),
          );
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

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
          // Dashboard
          InkWell(
            onTap: () => context.go(AppRoutes.adminHome),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dashboard_rounded,
                    color: Color(0xFF45474C),
                    size: 20,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Dashboard',
                    style: TextStyle(color: Color(0xFF45474C), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          // Căn hộ
          InkWell(
            onTap: () => context.go(AppRoutes.apartmentList),
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
          // Người dùng (Active)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFffdcc3),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Row(
              children: [
                Icon(Icons.group_rounded, color: Color(0xFF6E3900), size: 20),
                SizedBox(width: 4),
                Text(
                  'Người Dùng',
                  style: TextStyle(
                    color: Color(0xFF6E3900),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
