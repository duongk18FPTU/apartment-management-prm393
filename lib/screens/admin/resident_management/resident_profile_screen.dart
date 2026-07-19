import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/resident_provider.dart';
import 'resident_form_screen.dart';

class ResidentProfileScreen extends StatelessWidget {
  const ResidentProfileScreen({super.key, required this.resident});

  final UserModel resident;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident profile'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ResidentFormScreen(resident: resident),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () =>
                context.read<ResidentProvider>().toggleStatus(resident),
            icon: Icon(
              resident.isActive
                  ? Icons.person_off_outlined
                  : Icons.person_outline,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    child: Text(
                      resident.fullName.isEmpty
                          ? '?'
                          : resident.fullName.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resident.fullName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Chip(label: Text(resident.status.name)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(label: 'Email', value: resident.email),
                  _InfoRow(label: 'Phone', value: resident.phone),
                  _InfoRow(label: 'National ID', value: resident.nationalId),
                  _InfoRow(
                    label: 'Apartment',
                    value: resident.apartmentId ?? 'Not assigned',
                  ),
                  _InfoRow(label: 'Role', value: resident.role.name),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
