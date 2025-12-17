import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Ensure this package is added!
import 'theme.dart';
import 'signup_flow.dart';
import 'main.dart';
import 'data_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- QR SCANNER MODAL ---
  void _openQrScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        return SizedBox(
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
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty &&
                        barcodes.first.rawValue != null) {
                      _handleQrCode(barcodes.first.rawValue!);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Align the QR code within the frame",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleQrCode(String code) {
    try {
      final data = jsonDecode(code);
      // Expected format: {"username": "...", "password": "..."}
      if (data['username'] != null && data['password'] != null) {
        setState(() {
          _emailController.text = data['username'];
          _passwordController.text = data['password'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Credentials filled from QR!"),
            backgroundColor: Colors.green,
          ),
        );

        // Optional: Auto Login instantly if you want
        // _performLogin();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid QR Code"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _performLogin() async {
    // Only update if text fields are not empty to avoid wiping real data with empty strings
    if (_emailController.text.isNotEmpty) {
      // Save/Update Credentials in DataService (simulating a login check)
      await DataService().setUserInfo(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
    await DataService().setLoginState(true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
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

              // INPUTS
              _buildTextField(
                context,
                "Email or Phone",
                LucideIcons.mail,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context,
                "Password",
                LucideIcons.lock,
                isObscure: true,
                controller: _passwordController,
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

              // ACTION BUTTONS ROW
              Row(
                children: [
                  // QR SCAN BUTTON
                  InkWell(
                    onTap: _openQrScanner,
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

                  // LOGIN BUTTON
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _performLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TailOColors.coral,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
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
                          MaterialPageRoute(
                            builder: (_) =>
                                const SignupFlow(isAddingAnotherPet: false),
                          ),
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
                    onPressed: () async {
                      await DataService().setUserInfo(email: "guest@tailo.com");
                      await DataService().loadDemoData();
                      await DataService().setLoginState(true);
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainScaffold(),
                          ),
                        );
                      }
                    },
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
    BuildContext context,
    String hint,
    IconData icon, {
    bool isObscure = false,
    TextEditingController? controller,
  }) {
    final theme = Theme.of(context);
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
}
