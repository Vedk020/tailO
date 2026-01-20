import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../signup_state.dart';

class PetTypeStep extends StatelessWidget {
  final SignupController controller;
  const PetTypeStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSelectableCard(
            context,
            "Dog",
            LucideIcons.dog,
            controller.selectedPetType == 'dog',
            () => controller.setPetType('dog'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSelectableCard(
            context,
            "Cat",
            LucideIcons.cat,
            controller.selectedPetType == 'cat',
            () => controller.setPetType('cat'),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableCard(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? TailOColors.coral.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TailOColors.coral : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? TailOColors.coral : TailOColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? TailOColors.coral
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
