import 'package:flutter/material.dart';

import '../../../../providers/apartment_provider.dart';

class ApartmentDropdown extends StatelessWidget {
  const ApartmentDropdown({
    super.key,
    required this.provider,
    required this.value,
    required this.onChanged,
  });

  final ApartmentProvider provider;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String?>(
    initialValue: value,
    decoration: const InputDecoration(labelText: 'Apartment'),
    items: [
      const DropdownMenuItem<String?>(value: null, child: Text('No apartment')),
      ...provider.apartments.map(
        (apartment) => DropdownMenuItem<String?>(
          value: apartment.id,
          child: Text('${apartment.number} · ${apartment.building}'),
        ),
      ),
    ],
    onChanged: onChanged,
  );
}
