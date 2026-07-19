import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'routes.dart';
import 'theme.dart';

/// Root widget of the Apartment Building Management System.
///
/// Responsibilities:
/// - Provides [AuthProvider] to the entire widget tree via [ChangeNotifierProvider].
/// - Starts listening to Firebase Auth state as soon as the provider is created.
/// - Hands the router (built with [buildAppRouter]) to [MaterialApp.router].
/// - Applies the [buildAppTheme] design system from DESIGN.md.
class ApartmentApp extends StatelessWidget {
  const ApartmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider()..listenToAuthState(),
      child: Builder(
        builder: (context) {
          // Router must be built after AuthProvider is in the tree so that
          // GoRouter's refreshListenable can watch it.
          final authProvider = context.read<AuthProvider>();
          final router = buildAppRouter(authProvider);

          return MaterialApp.router(
            title: 'Modern Haven',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
