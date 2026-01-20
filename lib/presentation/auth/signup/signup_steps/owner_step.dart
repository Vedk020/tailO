import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../signup_state.dart';

class OwnerDetailsStep extends StatelessWidget {
  final SignupController controller;
  const OwnerDetailsStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.pickImage(true),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: theme.cardColor,
            backgroundImage: controller.ownerImageFile != null
                ? FileImage(controller.ownerImageFile!)
                : null,
            child: controller.ownerImageFile == null
                ? const Icon(
                    LucideIcons.camera,
                    size: 30,
                    color: TailOColors.muted,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          theme,
          "Your Name",
          controller.ownerNameController,
          LucideIcons.user,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          theme,
          "Email Address",
          controller.emailController,
          LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    String hint,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 18, color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: TailOColors.muted),
          hintText: hint,
          hintStyle: const TextStyle(color: TailOColors.muted),
        ),
      ),
    );
  }
}
