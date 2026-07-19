import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/apartment_model.dart';
import '../../../providers/apartment_provider.dart';
import '../../../utils/constants.dart';

class ApartmentListScreen extends StatefulWidget {
  const ApartmentListScreen({super.key});

  @override
  State<ApartmentListScreen> createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends State<ApartmentListScreen> {
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
      appBar: const _AppBar(),
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
                : provider.errorMessage != null
                ? Center(child: Text(provider.errorMessage!))
                : list.isEmpty
                ? const _EmptyState()
                : _ApartmentGrid(apartments: list),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

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
        onPressed: () {},
      ),
      title: const Text(
        'Danh sách căn hộ',
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tính năng thêm căn hộ đang phát triển'),
              ),
            );
          },
        ),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        16,
        AppSpacing.md,
        8,
      ),
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
                  label: 'Đã thuê',
                  isActive: activeFilter == ApartmentFilterType.occupied,
                  onTap: () => onFilterChanged(ApartmentFilterType.occupied),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Phòng trống',
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

class _ApartmentGrid extends StatelessWidget {
  const _ApartmentGrid({required this.apartments});

  final List<ApartmentModel> apartments;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemCount: apartments.length,
      itemBuilder: (context, index) {
        final apt = apartments[index];
        return _ApartmentCard(apartment: apt);
      },
    );
  }
}

class _ApartmentCard extends StatelessWidget {
  const _ApartmentCard({required this.apartment});

  final ApartmentModel apartment;

  String _getApartmentImageUrl(String number) {
    final images = [
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAzz_jQh3nSv4RTyioPKBlz6-TDSSSOfyC9iE7yejHiZ0at5nvfOTygiXWZOrBUJnynDyNTrapD5DMk8xNVXtP9tm5i4qE81mEBlLpUU8zdFhiCmt-PS0Nx3YjDw5l_lsC7DfJBrbpMwcwJrNww6iMkFwqWIydiQwLPizAjeupEW1Gt03sm_67tL3-Bo1cCZr42M8zv-JNYL06KTym_p5Q6OMwmgahn-geifcz_ST-FxkpS9ZbJ4WIoTA',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAJM8pHSPc37AkbZQRIw4Vjl2lzbd3CT-YPp1dBubDB-VpHCSytF1bUuC8jcsRf-hp4Xmk19b_mZNpaXWWxnlrFzH8xEfcF529NskRSnJhrTs1h3rUQsb6Ubs2h9m-9b1e75gV2zxoDj8syO882xIMrftHg5zY59BuuHznTCf43aU8uSinco5yZHJrlbtVo-rY7-OLoOEmjjoNt2S6NKE3i8yY50sziJSuMl1EcqawOY2LhofiNIp8dsA',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDJzTPMWJgElSteGV8OQASp0qIRu02K1cVmCwhT4Ei9JCjgLMCPd9UMKBW0j3ju5JMjoj9q3wvdAFkLwbtTDOu7rj0Vrz1O2HqO2HyXVhf6rSAXLONcBkVzNDe9_REGdi7ifx-NRZBCY0tPpxPJegtaYmhgovB4Q89fY8FT5sHHJ6hD08lx0V_mUIEhnigYTLzKLotgbW7gBUNUqGcy3J1LZX4J4Ypv4h2qWTogBdZ1u_NcJfNl6LMPQQ',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCD3ekhDfFsqMxLcv-B7GIiv7jqB7Rar5BxLPDf4SLKGtWZbwHkHBbaX7hCv8erP6o3nAD2Lgta_Ye4WBSzYDKNwvY3NLjba5a6PkMBGXX6jjK4F7lOPClIiYnSxTyB1rc8MY9MRhf8sdQl4Y1Rba8ppQb8MI74HrSjn0a8kUa6dLTdpn0JM6CZgcyIPLZkm-VEmoXuam4jfLx85vCbqGQaJsTRxeRaFzukLQfEzJgkwiNyBvupgvScuw',
    ];
    final hash = number.hashCode.abs();
    return images[hash % images.length];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ApartmentProvider>();
    final ownerName = apartment.ownerId != null
        ? provider.usersMap[apartment.ownerId]?.fullName ?? 'Đang tải...'
        : 'Chưa có chủ hộ';

    return GestureDetector(
      onTap: () {
        context.push('${AppRoutes.apartmentList}/${apartment.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x3375777D)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D1E293B),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with absolute room tag
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    _getApartmentImageUrl(apartment.number),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xE6091426),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'P.${apartment.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apartment.displayType == 'Studio'
                        ? 'Căn hộ Studio S2'
                        : 'Căn hộ cao cấp ${apartment.number}',
                    style: const TextStyle(
                      color: Color(0xFF091426),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chủ hộ: $ownerName',
                    style: const TextStyle(
                      color: Color(0xFF45474C),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Area and layer info
                  Row(
                    children: [
                      const Icon(
                        Icons.straighten_rounded,
                        color: Color(0xFF45474C),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${apartment.area.toStringAsFixed(0)} m²',
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.layers_rounded,
                        color: Color(0xFF45474C),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tầng ${apartment.floor}',
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 12),
                  // Status and rent price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: apartment.isOccupied
                              ? const Color(0x1F091426)
                              : const Color(0x1FD97706),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          apartment.isOccupied ? 'Đã lấp đầy' : 'Trống',
                          style: TextStyle(
                            color: apartment.isOccupied
                                ? const Color(0xFF091426)
                                : const Color(0xFFD97706),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${apartment.displayPrice}tr',
                              style: const TextStyle(
                                color: Color(0xFF091426),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '/tháng',
                              style: TextStyle(
                                color: Color(0xFF45474C),
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
          // Căn hộ (Active)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFffdcc3),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF6E3900),
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  'Căn Hộ',
                  style: TextStyle(
                    color: Color(0xFF6E3900),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Người dùng
          InkWell(
            onTap: () => context.go(AppRoutes.userList),
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
