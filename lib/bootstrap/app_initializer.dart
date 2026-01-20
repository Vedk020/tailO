import 'package:flutter/material.dart';
import 'dependency_injection.dart';

class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize DI
    await setupDependencies();

    // Add other init logic (Crashlytics, Logger, etc.)
  }
}
