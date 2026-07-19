import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../services/user_service.dart';

class UserApartmentControl extends StatelessWidget {
  const UserApartmentControl({
    super.key,
    required this.apartmentId,
    required this.apartments,
    required this.onChanged,
  });

  final String? apartmentId;
  final List<ApartmentOption> apartments;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = List<ApartmentOption>.of(apartments);
    if (apartmentId != null && !options.any((item) => item.id == apartmentId)) {
      options.add(ApartmentOption(id: apartmentId!, number: apartmentId!));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Căn hộ', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: apartmentId,
          isExpanded: true,
          decoration: const InputDecoration(
            hintText: 'Chọn căn hộ (không bắt buộc)',
            prefixIcon: Icon(Icons.apartment_outlined),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Chưa gán căn hộ'),
            ),
            ...options.map(
              (item) => DropdownMenuItem(
                value: item.id,
                child: Text('Căn hộ ${item.number}'),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
