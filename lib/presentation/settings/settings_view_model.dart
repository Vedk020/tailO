import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme_controller.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthService _authService;

  SettingsViewModel(this._authService);

  bool get isDark => ThemeController.isDark;

  void toggleTheme(bool isDark) {
    ThemeController.toggleTheme(isDark);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
