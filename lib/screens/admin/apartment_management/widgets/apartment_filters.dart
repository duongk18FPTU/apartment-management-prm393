import 'package:flutter/material.dart';

import '../../../../models/apartment_model.dart';
import '../../../../providers/apartment_provider.dart';

class ApartmentFilters extends StatelessWidget {
  const ApartmentFilters({super.key, required this.provider});

  final ApartmentProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: provider.setSearchQuery,
          decoration: const InputDecoration(
            hintText: 'Search by apartment or building',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FloorFilter(provider: provider)),
            const SizedBox(width: 12),
            Expanded(child: _StatusFilter(provider: provider)),
          ],
        ),
      ],
    );
  }
}

class _FloorFilter extends StatelessWidget {
  const _FloorFilter({required this.provider});

  final ApartmentProvider provider;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      isExpanded: true,
      initialValue: null,
      decoration: const InputDecoration(labelText: 'Floor'),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('All floors', overflow: TextOverflow.ellipsis),
        ),
        ...List.generate(
          12,
          (index) => DropdownMenuItem<int?>(
            value: index + 1,
            child: Text('Floor ${index + 1}', overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: provider.setFloor,
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.provider});

  final ApartmentProvider provider;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ApartmentStatus?>(
      isExpanded: true,
      initialValue: null,
      decoration: const InputDecoration(labelText: 'Status'),
      items: const [
        DropdownMenuItem<ApartmentStatus?>(
          value: null,
          child: Text('All statuses', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: ApartmentStatus.occupied,
          child: Text('Occupied', overflow: TextOverflow.ellipsis),
        ),
        DropdownMenuItem(
          value: ApartmentStatus.vacant,
          child: Text('Vacant', overflow: TextOverflow.ellipsis),
        ),
      ],
      onChanged: provider.setStatus,
    );
  }
}
