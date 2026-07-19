import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/apartment_provider.dart';
import '../providers/resident_provider.dart';
import '../screens/admin/apartment_management/apartment_list_screen.dart';
import '../screens/admin/resident_management/resident_list_screen.dart';
import 'theme.dart';

class ApartmentApp extends StatelessWidget {
  const ApartmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApartmentProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
      ],
      child: MaterialApp(
        title: 'Apartment Building Management System',
        theme: buildAppTheme(),
        initialRoute: '/',
        routes: {
          '/': (_) => const _Member2HomeScreen(),
          '/apartments': (_) => const ApartmentListScreen(),
          '/residents': (_) => const ResidentListScreen(),
        },
      ),
    );
  }
}

class _Member2HomeScreen extends StatelessWidget {
  const _Member2HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Building management')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Operations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Manage apartments and resident profiles from one place.'),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.home_work_outlined,
            title: 'Apartment management',
            description: 'View, filter, create, edit and assign residents.',
            onTap: () => Navigator.pushNamed(context, '/apartments'),
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            icon: Icons.people_outline,
            title: 'Resident management',
            description: 'Search profiles, update details and disable residents.',
            onTap: () => Navigator.pushNamed(context, '/residents'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.description, required this.onTap});

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
