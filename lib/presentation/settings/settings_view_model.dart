import 'package:flutter/foundation.dart';
import '../../../core/services/data_service.dart'; // ✅ Added DataService
import '../../../core/theme/theme_controller.dart';

class SettingsViewModel extends ChangeNotifier {
  // ✅ Removed AuthService dependency.
  SettingsViewModel();

  bool get isDark => ThemeController.isDark;

  void toggleTheme(bool isDark) {
    ThemeController.toggleTheme(isDark);
    notifyListeners();
  }

  Future<void> logout() async {
    // ✅ Using DataService to handle the logout and cache clearing
    await DataService().logout();
  }
}
