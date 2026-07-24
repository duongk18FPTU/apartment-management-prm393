import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/apartment_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/apartment_provider.dart';
import '../../../providers/resident_provider.dart';
import 'apartment_form_screen.dart';
import 'widgets/apartment_detail_widgets.dart';

class ApartmentDetailScreen extends StatelessWidget {
  const ApartmentDetailScreen({
    super.key,
    this.apartment,
    this.apartmentId,
    this.initialApartment,
  });

  final ApartmentModel? apartment;
  final String? apartmentId;
  final ApartmentModel? initialApartment;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApartmentProvider>();
    final targetApartment =
        apartment ??
        provider.selectedApartment ??
        initialApartment ??
        (apartmentId != null
            ? provider.apartments.cast<ApartmentModel?>().firstWhere(
                (a) => a?.id == apartmentId,
                orElse: () => null,
              )
            : null);

    if (targetApartment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Apartment details')),
        body: const Center(child: Text('Apartment not found.')),
      );
    }

    final ownerName = targetApartment.ownerId != null
        ? provider.usersMap[targetApartment.ownerId]?.fullName ??
              targetApartment.ownerId!
        : 'Not assigned';

    return Scaffold(
      appBar: AppBar(
        title: Text('Apartment ${targetApartment.number}'),
        actions: [
          IconButton(
            tooltip: 'Edit apartment',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ApartmentFormScreen(apartment: targetApartment),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete apartment',
            onPressed: () => _confirmDelete(context, targetApartment),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ApartmentDetails(apartment: targetApartment, ownerName: ownerName),
          const SizedBox(height: 24),
          Text(
            'Residents (${targetApartment.residentIds.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (targetApartment.residentIds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No residents assigned.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...targetApartment.residentIds.map((id) {
              final resUser = provider.usersMap[id];
              final resName = resUser?.fullName ?? id;
              final isOwner = id == targetApartment.ownerId;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(resName),
                subtitle: Text(isOwner ? 'Owner' : 'Resident'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () =>
                      context.read<ApartmentProvider>().unassignResident(
                        apartmentId: targetApartment.id,
                        residentId: id,
                      ),
                ),
              );
            }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _assignResident(context, targetApartment),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Assign resident'),
          ),
        ],
      ),
    );
  }

  Future<void> _assignResident(BuildContext context, ApartmentModel apt) async {
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
        apartmentId: apt.id,
        residentId: resident.uid,
        asOwner: apt.ownerId == null,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã gán cư dân ${resident.fullName} vào căn hộ'),
          backgroundColor: const Color(0xFF0D9488),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gán cư dân: $error'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, ApartmentModel apt) async {
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
      await context.read<ApartmentProvider>().delete(apt.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
