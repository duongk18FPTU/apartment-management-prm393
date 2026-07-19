import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'firebase_options.dart';

/// Application entry point.
///
/// Responsibilities (intentionally minimal — no business logic here):
/// 1. Initialise Firebase.
/// 2. Lock orientation to portrait (standard for a mobile-first app).
/// 3. Mount [ApartmentApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise locale date formatting for Vietnamese ('vi_VN')
  await initializeDateFormatting('vi_VN', null);

  // Initialise Firebase with the generated config from `flutterfire configure`
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Portrait-only orientation lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive status bar — transparent overlay on the primary colour
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ApartmentApp());
}
