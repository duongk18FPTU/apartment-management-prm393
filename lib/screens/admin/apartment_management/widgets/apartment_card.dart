import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/apartment_model.dart';
import '../../../../providers/apartment_provider.dart';

class ApartmentCard extends StatelessWidget {
  const ApartmentCard({super.key, required this.apartment});

  final ApartmentModel apartment;

  String _getApartmentImageUrl(String number) {
    final id = number.replaceAll(RegExp(r'\D'), '');
    final typeId = (int.tryParse(id) ?? 0) % 3 + 1;
    return 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=600&q=80&sig=$typeId';
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = apartment.ownerId != null
        ? context
                  .watch<ApartmentProvider>()
                  .usersMap[apartment.ownerId]
                  ?.fullName ??
              'Chưa đăng ký'
        : 'Chưa đăng ký';

    final isOccupied = apartment.isOccupied;

    return GestureDetector(
      onTap: () => context.push('/admin/apartments/${apartment.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05091426),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with room tag
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  Image.network(
                    _getApartmentImageUrl(apartment.number),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF1E293B),
                        child: const Center(
                          child: Icon(
                            Icons.apartment_rounded,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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
            // Info Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    apartment.displayType == 'Studio'
                        ? 'Căn hộ Studio ${apartment.number}'
                        : 'Căn hộ cao cấp ${apartment.number}',
                    style: const TextStyle(
                      color: Color(0xFF091426),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chủ hộ: $ownerName',
                    style: const TextStyle(
                      color: Color(0xFF45474C),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOccupied
                                ? const Color(0x1F0D9488)
                                : const Color(0x1FD97706),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            isOccupied ? 'Đã lấp đầy' : 'Trống',
                            style: TextStyle(
                              color: isOccupied
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFFD97706),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RichText(
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
