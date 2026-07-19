import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/apartment_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/apartment_provider.dart';
import '../../../utils/constants.dart';

class ApartmentDetailScreen extends StatefulWidget {
  const ApartmentDetailScreen({super.key, this.apartmentId, this.apartment})
    : assert(
        apartmentId != null || apartment != null,
        'Either apartmentId or apartment must be provided.',
      );

  final String? apartmentId;
  final ApartmentModel? apartment;

  @override
  State<ApartmentDetailScreen> createState() => _ApartmentDetailScreenState();
}

class _ApartmentDetailScreenState extends State<ApartmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.apartmentId ?? widget.apartment!.id;
      context.read<ApartmentProvider>().loadSelectedApartment(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApartmentProvider>();
    final apt = provider.selectedApartment;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
            provider.clearSelection();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.apartmentList);
            }
          },
        ),
        title: Text(
          apt != null ? 'Chi tiết Căn hộ ${apt.number}' : 'Chi tiết Căn hộ',
          style: const TextStyle(
            color: Color(0xFF091426),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF091426)),
            onPressed: () {},
          ),
        ],
      ),
      body: provider.isLoadingDetail || apt == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BentoHeroCard(apartment: apt),
                      const SizedBox(height: 24),
                      _OwnerSection(
                        owner: provider.selectedOwner,
                        onEdit: () => _showOwnerAssignment(context, provider),
                      ),
                      const SizedBox(height: 24),
                      _ResidentsSection(
                        residents: provider.selectedResidents,
                        onAddResident: () =>
                            _showResidentAssignment(context, provider),
                        onRemoveResident: (residentId) =>
                            provider.removeResidentFromSelected(residentId),
                      ),
                      const SizedBox(
                        height: 100,
                      ), // Spacing for absolute footer
                    ],
                  ),
                ),
                _FixedFooter(
                  onEditInfo: () => _showEditInfoDialog(context, provider, apt),
                  onAddResident: () =>
                      _showResidentAssignment(context, provider),
                ),
              ],
            ),
    );
  }

  void _showEditInfoDialog(
    BuildContext context,
    ApartmentProvider provider,
    ApartmentModel apt,
  ) {
    final areaController = TextEditingController(text: apt.area.toString());
    final typeController = TextEditingController(text: apt.displayType);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thay đổi thông tin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: areaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Diện tích (m²)'),
              ),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(
                  labelText: 'Loại căn hộ (ví dụ: 2PN - 2WC)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final area = double.tryParse(areaController.text) ?? apt.area;
                provider.updateSelectedApartmentDetails(
                  area: area,
                  type: typeController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showOwnerAssignment(BuildContext context, ApartmentProvider provider) {
    // Show dialog to choose an owner from residents list
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final residents = provider.selectedResidents;
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Gán chủ hộ mới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (residents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Vui lòng thêm cư dân trước khi gán chủ hộ.',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: residents.length,
                    itemBuilder: (context, index) {
                      final res = residents[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: res.avatarUrl != null
                              ? NetworkImage(res.avatarUrl!)
                              : null,
                          child: res.avatarUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(res.fullName),
                        subtitle: Text(res.phone),
                        onTap: () {
                          provider.assignOwnerToSelected(res.uid);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.clear, color: Colors.white),
                ),
                title: const Text('Gỡ chủ hộ hiện tại'),
                onTap: () {
                  provider.assignOwnerToSelected(null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResidentAssignment(
    BuildContext context,
    ApartmentProvider provider,
  ) {
    // Fetch all users to assign
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FutureBuilder<List<UserModel>>(
          future: provider.getUnassignedResidents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final list = snapshot.data ?? [];
            return Container(
              padding: const EdgeInsets.all(16),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Gán cư dân mới',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (list.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Không có cư dân trống nào (chưa được gán căn hộ).',
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final user = list[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user.fullName),
                            subtitle: Text(user.phone),
                            onTap: () {
                              provider.assignResidentToSelected(user.uid);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BentoHeroCard extends StatelessWidget {
  const _BentoHeroCard({required this.apartment});

  final ApartmentModel apartment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E293B),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      ? const Color(0xFF85F8C4)
                      : const Color(0xFFffdcc3),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  apartment.isOccupied ? 'Đang sử dụng' : 'Phòng trống',
                  style: TextStyle(
                    color: apartment.isOccupied
                        ? const Color(0xFF002114)
                        : const Color(0xFF6E3900),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.apartment_rounded,
                size: 28,
                color: Color(0x22091426),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Phòng ${apartment.number}',
            style: const TextStyle(
              color: Color(0xFF091426),
              fontSize: 30,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.02,
            ),
          ),
          const Text(
            'Chung cư Horizon Tower',
            style: TextStyle(color: Color(0xFF45474C), fontSize: 14),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeroDetailItem(
                label: 'Tầng',
                value: apartment.floor.toString().padLeft(2, '0'),
              ),
              _HeroDetailItem(
                label: 'Diện tích',
                value: '${apartment.area.toStringAsFixed(0)}m²',
              ),
              _HeroDetailItem(
                label: 'Loại',
                value: apartment.displayType,
                alignRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroDetailItem extends StatelessWidget {
  const _HeroDetailItem({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF45474C),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF091426),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _OwnerSection extends StatelessWidget {
  const _OwnerSection({required this.owner, required this.onEdit});

  final UserModel? owner;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chủ căn hộ',
              style: TextStyle(
                color: Color(0xFF091426),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: onEdit,
              child: const Text(
                'Chỉnh sửa',
                style: TextStyle(
                  color: Color(0xFF091426),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (owner == null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Chưa gán chủ căn hộ',
              style: TextStyle(color: Color(0xFF75777D)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D1E293B),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: owner!.avatarUrl != null
                      ? NetworkImage(owner!.avatarUrl!)
                      : null,
                  child: owner!.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner!.fullName,
                        style: const TextStyle(
                          color: Color(0xFF091426),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 14,
                            color: Color(0xFF45474C),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            owner!.phone,
                            style: const TextStyle(
                              color: Color(0xFF45474C),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail_rounded,
                            size: 14,
                            color: Color(0xFF45474C),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            owner!.email,
                            style: const TextStyle(
                              color: Color(0xFF45474C),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF091426),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ResidentsSection extends StatelessWidget {
  const _ResidentsSection({
    required this.residents,
    required this.onAddResident,
    required this.onRemoveResident,
  });

  final List<UserModel> residents;
  final VoidCallback onAddResident;
  final ValueChanged<String> onRemoveResident;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cư dân đang cư trú',
              style: TextStyle(
                color: Color(0xFF091426),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFffdcc3),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '${residents.length} người',
                style: const TextStyle(
                  color: Color(0xFF6E3900),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (residents.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Chưa có cư dân',
              style: TextStyle(color: Color(0xFF75777D)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: residents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final res = residents[index];
              return Dismissible(
                key: Key(res.uid),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) => onRemoveResident(res.uid),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D1E293B),
                        offset: Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: res.avatarUrl != null
                            ? NetworkImage(res.avatarUrl!)
                            : null,
                        child: res.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              res.fullName,
                              style: const TextStyle(
                                color: Color(0xFF091426),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              res.phone,
                              style: const TextStyle(
                                color: Color(0xFF45474C),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF45474C),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        // Dashed Add button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: const BorderSide(color: Color(0xFF75777D), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onAddResident,
          icon: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Color(0xFF45474C),
          ),
          label: const Text(
            'GÁN CƯ DÂN MỚI',
            style: TextStyle(
              color: Color(0xFF45474C),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _FixedFooter extends StatelessWidget {
  const _FixedFooter({required this.onEditInfo, required this.onAddResident});

  final VoidCallback onEditInfo;
  final VoidCallback onAddResident;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          16,
          AppSpacing.md,
          24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xD9FFFFFF),
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF091426),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: onEditInfo,
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text(
                'Thay đổi thông tin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAddResident,
              child: const Text(
                'GÁN CƯ DÂN MỚI',
                style: TextStyle(
                  color: Color(0xFF091426),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
