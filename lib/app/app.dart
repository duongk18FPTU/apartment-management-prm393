import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/request_provider.dart';
import 'routes.dart';
import 'theme.dart';

/// Root widget of the Apartment Building Management System.
class ApartmentApp extends StatelessWidget {
  const ApartmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..listenToAuthState(),
        ),
        ChangeNotifierProvider<RequestProvider>(
          create: (_) => RequestProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
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
