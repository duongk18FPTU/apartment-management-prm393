import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/apartment_provider.dart';
import '../../../providers/resident_provider.dart';
import 'resident_form_screen.dart';
import 'resident_profile_screen.dart';

class ResidentListScreen extends StatelessWidget {
  const ResidentListScreen({super.key, this.provider});

  final ResidentProvider? provider;

  @override
  Widget build(BuildContext context) {
    final view = const _ResidentListView();
    final residentScope = provider == null
        ? ChangeNotifierProvider(
            create: (_) => ResidentProvider()..loadResidents(),
            child: view,
          )
        : ChangeNotifierProvider<ResidentProvider>.value(
            value: provider!,
            child: view,
          );
    return ChangeNotifierProvider(
      create: (_) => ApartmentProvider(),
      child: residentScope,
    );
  }
}

class _ResidentListView extends StatelessWidget {
  const _ResidentListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResidentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Residents'),
        actions: [
          IconButton(
            onPressed: provider.loadResidents,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadResidents,
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              'Resident directory',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('${provider.residents.length} resident profiles'),
            const SizedBox(height: 24),
            TextField(
              onChanged: provider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search by name, phone or apartment',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserStatus?>(
              initialValue: null,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem<UserStatus?>(
                  value: null,
                  child: Text('All statuses'),
                ),
                DropdownMenuItem(
                  value: UserStatus.active,
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: UserStatus.inactive,
                  child: Text('Inactive'),
                ),
              ],
              onChanged: provider.setStatus,
            ),
            const SizedBox(height: 16),
            if (provider.isLoading && provider.residents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.errorMessage != null &&
                provider.residents.isEmpty)
              _ResidentError(
                message: provider.errorMessage!,
                onRetry: provider.loadResidents,
              )
            else if (provider.filteredResidents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No residents match your filters.'),
                ),
              )
            else
              ...provider.filteredResidents.map(
                (resident) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResidentCard(resident: resident),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResidentFormScreen())),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add resident'),
      ),
    );
  }
}

class _ResidentCard extends StatelessWidget {
  const _ResidentCard({required this.resident});

  final UserModel resident;

  @override
  Widget build(BuildContext context) {
    final color = resident.isActive
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.error;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResidentProfileScreen(resident: resident),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .12),
                foregroundColor: color,
                child: Text(
                  resident.fullName.isEmpty
                      ? '?'
                      : resident.fullName.substring(0, 1).toUpperCase(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resident.fullName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(resident.apartmentId ?? 'No apartment assigned'),
                    Text(resident.phone),
                  ],
                ),
              ),
              Chip(label: Text(resident.status.name)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResidentError extends StatelessWidget {
  const _ResidentError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        Text(message),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
