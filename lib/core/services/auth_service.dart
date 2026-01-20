import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storage;

  // Reactive State
  final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);

  // User Data (Private)
  String? _name;
  String? _email;
  String? _image;

  AuthService(this._storage);

  // Getters
  bool get isLoggedIn => isLoggedInNotifier.value;
  String get userName => _name ?? "Guest";
  String get userEmail => _email ?? "";
  String get userImage => _image ?? "assets/images/pfp.jpeg";

  Future<void> init() async {
    // Load Login State
    isLoggedInNotifier.value = _storage.getBool(StorageService.keyLogin);

    // Load Profile
    final info = _storage.getStringList(StorageService.keyUser);
    if (info != null && info.length >= 3) {
      _name = info[0];
      _email = info[1];
      _image = info[2];
    }
  }

  Future<void> login(String email, String password) async {
    // In a real app, verify password with backend here.
    await _storage.setBool(StorageService.keyLogin, true);
    isLoggedInNotifier.value = true;
  }

  Future<void> logout() async {
    await _storage.remove(StorageService.keyLogin);
    await _storage.remove(StorageService.keyUser);

    _name = null;
    _email = null;
    _image = null;
    isLoggedInNotifier.value = false;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? imagePath,
  }) async {
    _name = name;
    _email = email;
    if (imagePath != null) _image = imagePath;

    // Save strictly structured list
    await _storage.setStringList(StorageService.keyUser, [
      _name!,
      _email!,
      _image ?? "",
    ]);
  }
}
