import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // REQUIRED
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../bootstrap/dependency_injection.dart';
// Core
import '../../../../core/theme/colors.dart';
import '../../home/main_scaffold.dart';
import '../signup/signup_flow.dart';

// Logic
import 'login_view_model.dart';
import 'login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ✅ FIX: Use sl() to create the ViewModel with dependencies
      create: (_) => sl<LoginViewModel>(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<LoginViewModel>();
    final state = viewModel.state;

    // Listener for Side Effects (Navigation/Snackbars)
    // Note: Ideally use a mixin or specific listener widget for this in prod
    if (state.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      });
    }

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: TailOColors.error,
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: TailOColors.coral.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('assets/images/appLogo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Inputs
              _buildTextField(
                theme,
                "Email or Phone",
                LucideIcons.mail,
                viewModel.emailController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                theme,
                "Password",
                LucideIcons.lock,
                viewModel.passwordController,
                isObscure: true,
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: TailOColors.coral,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  // QR Button
                  InkWell(
                    onTap: () => _openQrScanner(context, viewModel),
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(
                        LucideIcons.qrCode,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Login Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : viewModel.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TailOColors.coral,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Footer Links
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: TailOColors.muted),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupFlow()),
                        ),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: state.isLoading ? null : viewModel.loginAsGuest,
                    child: const Text(
                      "Skip & Sign in Later",
                      style: TextStyle(
                        color: TailOColors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: TailOColors.muted, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: TailOColors.muted),
        ),
      ),
    );
  }

  void _openQrScanner(BuildContext context, LoginViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              title: const Text(
                "Scan Login Key",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(LucideIcons.x, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    viewModel.handleQrCode(barcodes.first.rawValue!);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
