import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/constants.dart';
import 'widgets/user_feedback_states.dart';
import 'widgets/user_filter_bar.dart';
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
    context.read<UserProvider>().listenToUsers();
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
      appBar: AppBar(title: const Text('Người dùng')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.userCreate),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Thêm người dùng'),
      ),
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
            _InlineError(message: provider.errorMessage!),
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
          96,
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
