import 'package:flutter/material.dart';

import '../../../../models/apartment_model.dart';

class ApartmentFormFields extends StatelessWidget {
  const ApartmentFormFields({
    super.key,
    required this.numberController,
    required this.buildingController,
    required this.floorController,
    required this.areaController,
    required this.typeController,
    required this.priceController,
    required this.status,
    required this.onStatusChanged,
  });

  final TextEditingController numberController;
  final TextEditingController buildingController;
  final TextEditingController floorController;
  final TextEditingController areaController;
  final TextEditingController typeController;
  final TextEditingController priceController;
  final ApartmentStatus status;
  final ValueChanged<ApartmentStatus?> onStatusChanged;

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
        TextFormField(
          controller: typeController,
          decoration: const InputDecoration(
            labelText: 'Apartment type',
            hintText: 'Example: 2BR - 2BA',
          ),
          validator: _required,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: priceController,
          decoration: const InputDecoration(labelText: 'Price (million VND)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final price = double.tryParse(value ?? '');
            if (price == null || price <= 0) {
              return 'Enter a valid positive price.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ApartmentStatus>(
          initialValue: status,
          decoration: const InputDecoration(labelText: 'Status'),
          items: ApartmentStatus.values
              .map(
                (value) =>
                    DropdownMenuItem(value: value, child: Text(value.name)),
              )
              .toList(),
          onChanged: onStatusChanged,
        ),
      ],
    );
  }
}
