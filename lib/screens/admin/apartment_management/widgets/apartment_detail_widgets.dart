import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/apartment_model.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/resident_provider.dart';

class ApartmentDetailRow extends StatelessWidget {
  const ApartmentDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class ApartmentDetails extends StatelessWidget {
  const ApartmentDetails({
    super.key,
    required this.apartment,
    required this.ownerName,
  });

  final ApartmentModel apartment;
  final String ownerName;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apartment details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          ApartmentDetailRow(label: 'Number', value: apartment.number),
          ApartmentDetailRow(label: 'Building', value: apartment.building),
          ApartmentDetailRow(label: 'Floor', value: apartment.floor.toString()),
          ApartmentDetailRow(
            label: 'Area',
            value: '${apartment.area.toStringAsFixed(1)} m²',
          ),
          ApartmentDetailRow(
            label: 'Rent price',
            value: '${apartment.displayPrice} mil VND / month',
          ),
          ApartmentDetailRow(label: 'Room type', value: apartment.displayType),
          ApartmentDetailRow(label: 'Status', value: apartment.status.name),
          ApartmentDetailRow(label: 'Owner', value: ownerName),
        ],
      ),
    ),
  );
}

class ResidentPickerDialog extends StatelessWidget {
  const ResidentPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResidentProvider>();
    Widget content;
    if (provider.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (provider.residents.isEmpty) {
      content = const Text('No residents available.');
    } else {
      content = ListView(
        shrinkWrap: true,
        children: provider.residents
            .map((resident) => _ResidentOption(resident: resident))
            .toList(),
      );
    }
    return AlertDialog(
      title: const Text('Assign resident'),
      content: SizedBox(width: 360, child: content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ResidentOption extends StatelessWidget {
  const _ResidentOption({required this.resident});

  final UserModel resident;

  @override
  Widget build(BuildContext context) {
    final canAssign = resident.apartmentId == null;
    return ListTile(
      title: Text(resident.fullName),
      subtitle: Text(resident.apartmentId ?? 'No apartment'),
      enabled: canAssign,
      onTap: canAssign ? () => Navigator.pop(context, resident) : null,
    );
  }
}
