import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/apartment_model.dart';
import '../../../providers/apartment_provider.dart';
import '../../../utils/constants.dart';
import 'widgets/apartment_card.dart';

class ApartmentListScreen extends StatelessWidget {
  const ApartmentListScreen({super.key, this.provider});

  final ApartmentProvider? provider;

  @override
  Widget build(BuildContext context) {
    if (provider != null) {
      return ChangeNotifierProvider<ApartmentProvider>.value(
        value: provider!,
        child: const _ApartmentListContent(),
      );
    }
    try {
      context.read<ApartmentProvider>();
      return const _ApartmentListContent();
    } catch (_) {
      return ChangeNotifierProvider(
        create: (_) => ApartmentProvider()..initialize(),
        child: const _ApartmentListContent(),
      );
    }
  }
}

class _ApartmentListContent extends StatefulWidget {
  const _ApartmentListContent();

  @override
  State<_ApartmentListContent> createState() => _ApartmentListContentState();
}

class _ApartmentListContentState extends State<_ApartmentListContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApartmentProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApartmentProvider>();
    final list = provider.filteredApartments;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Danh sách căn hộ'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => context.read<ApartmentProvider>().initialize(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'apartment_list_fab',
        backgroundColor: const Color(0xFFFE932C),
        foregroundColor: Colors.white,
        onPressed: () => context.push(AppRoutes.apartmentForm),
        icon: const Icon(Icons.add_home_work_rounded),
        label: const Text('Thêm căn hộ'),
      ),
      body: Column(
        children: [
          _SearchAndFilterBar(
            searchController: _searchController,
            searchQuery: provider.searchQuery,
            onSearchChanged: provider.setSearchQuery,
            activeFilter: provider.filterType,
            onFilterChanged: provider.setFilterType,
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                ? const _EmptyState()
                : _ApartmentList(apartments: list),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ApartmentFilterType activeFilter;
  final ValueChanged<ApartmentFilterType> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, 12),
      child: Column(
        children: [
          // Search Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm căn hộ, chủ hộ...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF75777D),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips Horizontal Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  isActive: activeFilter == ApartmentFilterType.all,
                  onTap: () => onFilterChanged(ApartmentFilterType.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Tầng 1-3',
                  isActive: activeFilter == ApartmentFilterType.floor1to3,
                  onTap: () => onFilterChanged(ApartmentFilterType.floor1to3),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Tầng 4-6',
                  isActive: activeFilter == ApartmentFilterType.floor4to6,
                  onTap: () => onFilterChanged(ApartmentFilterType.floor4to6),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Đã lấp đầy',
                  isActive: activeFilter == ApartmentFilterType.occupied,
                  onTap: () => onFilterChanged(ApartmentFilterType.occupied),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Trống',
                  isActive: activeFilter == ApartmentFilterType.vacant,
                  onTap: () => onFilterChanged(ApartmentFilterType.vacant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF091426) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF45474C),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ApartmentList extends StatelessWidget {
  const _ApartmentList({required this.apartments});

  final List<ApartmentModel> apartments;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApartmentProvider>().initialize();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl * 3,
        ),
        itemCount: apartments.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final apt = apartments[index];
          return ApartmentCard(apartment: apt);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment_rounded, size: 48, color: Color(0xFF75777D)),
          SizedBox(height: 8),
          Text(
            'Không tìm thấy căn hộ nào',
            style: TextStyle(color: Color(0xFF75777D)),
          ),
        ],
      ),
    );
  }
}
