import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../domain/repositories/auth_repository.dart'; // Import Repo
import 'login_state.dart';

class LoginViewModel extends ChangeNotifier {
  // 1. Inject Repository
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository); // ✅ Constructor added

  // UI State
  LoginState _state = LoginState.initial();
  LoginState get state => _state;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _setState(LoginState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _setState(LoginState.error("Please enter email and password."));
      return;
    }

    _setState(LoginState.loading());

    try {
      // 2. Use Repository
      await _authRepository.login(email, password);
      _setState(LoginState.success());
    } catch (e) {
      _setState(LoginState.error("Login failed."));
    }
  }

  void handleQrCode(String rawCode) {
    try {
      final data = jsonDecode(rawCode);
      if (data['username'] != null) {
        emailController.text = data['username'];
        if (data['password'] != null)
          passwordController.text = data['password'];
        notifyListeners();
      }
    } catch (_) {}
  }

  // Guest mock
  Future<void> loginAsGuest() async {
    await login(); // Simplified for now
  }
}
