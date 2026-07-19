import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/apartment_provider.dart';
import 'apartment_form_screen.dart';
import 'widgets/apartment_card.dart';
import 'widgets/apartment_filters.dart';
import 'widgets/apartment_states.dart';

class ApartmentListScreen extends StatelessWidget {
  const ApartmentListScreen({super.key, this.provider});

  final ApartmentProvider? provider;

  @override
  Widget build(BuildContext context) {
    final view = const _ApartmentListView();
    if (provider != null) {
      return ChangeNotifierProvider<ApartmentProvider>.value(
        value: provider!,
        child: view,
      );
    }
    return ChangeNotifierProvider(
      create: (_) => ApartmentProvider()..loadApartments(),
      child: view,
    );
  }
}

class _ApartmentListView extends StatelessWidget {
  const _ApartmentListView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApartmentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartments'),
        actions: [
          IconButton(
            onPressed: provider.loadApartments,
            tooltip: 'Refresh apartments',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadApartments,
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text('Building overview', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${provider.apartments.length} apartments in the building'),
            const SizedBox(height: 24),
            ApartmentFilters(provider: provider),
            const SizedBox(height: 16),
            _ApartmentResults(provider: provider),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ApartmentFormScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add apartment'),
      ),
    );
  }
}

class _ApartmentResults extends StatelessWidget {
  const _ApartmentResults({required this.provider});

  final ApartmentProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.apartments.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (provider.errorMessage != null && provider.apartments.isEmpty) {
      return ApartmentErrorState(message: provider.errorMessage!, onRetry: provider.loadApartments);
    }
    if (provider.filteredApartments.isEmpty) return const ApartmentEmptyState();
    return Column(
      children: provider.filteredApartments
          .map((apartment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ApartmentCard(apartment: apartment),
              ))
          .toList(),
    );
  }
}
