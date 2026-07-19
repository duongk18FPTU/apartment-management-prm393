import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/apartment_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/apartment_provider.dart';
import '../../../providers/resident_provider.dart';
import 'apartment_form_screen.dart';
import 'widgets/apartment_detail_widgets.dart';

class ApartmentDetailScreen extends StatelessWidget {
  const ApartmentDetailScreen({super.key, required this.apartment});

  final ApartmentModel apartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apartment ${apartment.number}'),
        actions: [
          IconButton(
            tooltip: 'Edit apartment',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ApartmentFormScreen(apartment: apartment),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete apartment',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ApartmentDetails(apartment: apartment),
          const SizedBox(height: 24),
          Text(
            'Residents (${apartment.residentIds.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...apartment.residentIds.map(
            (id) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(id),
              subtitle: Text(id == apartment.ownerId ? 'Owner' : 'Resident'),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _assignResident(context),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Assign resident'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignResident(BuildContext context) async {
    final resident = await showDialog<UserModel>(
      context: context,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => ResidentProvider()..loadResidents(),
        child: const ResidentPickerDialog(),
      ),
    );
    if (resident == null || !context.mounted) return;
    try {
      await context.read<ApartmentProvider>().assignResident(
        apartmentId: apartment.id,
        residentId: resident.uid,
        asOwner: true,
      );
      if (context.mounted) Navigator.of(context).pop();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to assign resident.')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete apartment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ApartmentProvider>().delete(apartment.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
