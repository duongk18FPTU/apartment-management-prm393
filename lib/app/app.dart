import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/complaint_provider.dart';
import '../providers/request_provider.dart';
import '../providers/user_provider.dart';
import '../providers/apartment_provider.dart';
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
          create: (context) => AuthProvider()..listenToAuthState(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<ApartmentProvider>(
          create: (context) => ApartmentProvider()..initialize(),
        ),
        ChangeNotifierProvider<RequestProvider>(
          create: (context) => RequestProvider(),
        ),
        ChangeNotifierProvider<BillProvider>(
          create: (context) => BillProvider(),
        ),
        ChangeNotifierProvider<ComplaintProvider>(
          create: (context) => ComplaintProvider(),
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
            locale: const Locale('vi', 'VN'),
            supportedLocales: const [Locale('vi', 'VN')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
