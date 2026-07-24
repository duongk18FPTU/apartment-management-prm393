import 'package:flutter/material.dart';

import '../../../../models/apartment_model.dart';

class ApartmentFormFields extends StatelessWidget {
  const ApartmentFormFields({
    super.key,
    required this.numberController,
    required this.buildingController,
    required this.floorController,
    required this.areaController,
    required this.priceController,
    required this.type,
    required this.onTypeChanged,
    required this.status,
    required this.onStatusChanged,
  });

  final TextEditingController numberController;
  final TextEditingController buildingController;
  final TextEditingController floorController;
  final TextEditingController areaController;
  final TextEditingController priceController;
  final String type;
  final ValueChanged<String?> onTypeChanged;
  final ApartmentStatus status;
  final ValueChanged<ApartmentStatus?> onStatusChanged;

  static const List<String> availableTypes = [
    'Studio',
    '1PN - 1WC',
    '2PN - 1WC',
    '2PN - 2WC',
    '3PN - 2WC',
    'Penthouse',
  ];

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: numberController,
          decoration: const InputDecoration(labelText: 'Apartment number'),
          validator: _required,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: buildingController,
          decoration: const InputDecoration(labelText: 'Building'),
          validator: _required,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: floorController,
                decoration: const InputDecoration(labelText: 'Floor'),
                keyboardType: TextInputType.number,
                validator: (value) => int.tryParse(value ?? '') == null
                    ? 'Enter a valid floor.'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: areaController,
                decoration: const InputDecoration(labelText: 'Area (m²)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => double.tryParse(value ?? '') == null
                    ? 'Enter a valid area.'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Rent price (mil VND)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid price.';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: availableTypes.contains(type)
                    ? type
                    : availableTypes.first,
                decoration: const InputDecoration(labelText: 'Room type'),
                items: availableTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: onTypeChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ApartmentStatus>(
          isExpanded: true,
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: ApartmentStatus.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onStatusChanged,
        ),
      ],
    );
  }
}
