import 'package:flutter/material.dart';

class ApartmentApp extends StatelessWidget {
  const ApartmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apartment Building Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E293B)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Apartment Management App Initialized'),
        ),
      ),
    );
  }
}
