import 'package:flutter/material.dart';

import '../../../../models/apartment_model.dart';
import '../apartment_detail_screen.dart';

class ApartmentCard extends StatelessWidget {
  const ApartmentCard({super.key, required this.apartment});

  final ApartmentModel apartment;

  @override
  Widget build(BuildContext context) {
    final color = apartment.isOccupied
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.secondary;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ApartmentDetailScreen(apartment: apartment),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .12),
                foregroundColor: color,
                child: const Icon(Icons.home_work_outlined),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apartment ${apartment.number}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${apartment.building} · Floor ${apartment.floor} · '
                      '${apartment.area.toStringAsFixed(0)} m²',
                    ),
                  ],
                ),
              ),
              Chip(label: Text(apartment.status.name)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
