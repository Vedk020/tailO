import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/data_service.dart';
import '../../../../data/models/pet_model.dart';
import '../../../../presentation/auth/signup/signup_flow.dart';
import '../../../../core/theme/colors.dart';

class PetListCard extends StatelessWidget {
  final List<Pet> pets;
  final Pet activePet;

  const PetListCard({super.key, required this.pets, required this.activePet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...pets.map((pet) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _buildPetAvatar(
                  context,
                  pet.image,
                  pet.name,
                  pet.id,
                  isSelected: pet.id == activePet.id,
                  isConnected: pet.isConnected,
                  onTap: () => DataService().switchPet(pet.id),
                ),
              );
            }),
            _buildAddPetButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPetAvatar(
    BuildContext context,
    String assetPath,
    String name,
    String id, {
    required bool isSelected,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final Color dotColor = isConnected
        ? const Color(0xFF34C759)
        : TailOColors.muted;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: TailOColors.coral, width: 2.5)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: isSelected
                      ? theme.cardColor
                      : theme.cardColor.withValues(alpha: 0.5),
                  backgroundImage: DataService.getImageProvider(assetPath),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? theme.textTheme.bodyLarge?.color
                  : TailOColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SignupFlow(isAddingAnotherPet: true),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TailOColors.muted, width: 1.5),
            ),
            child: const Icon(
              LucideIcons.plus,
              color: TailOColors.muted,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Add",
            style: TextStyle(
              fontSize: 11,
              color: TailOColors.muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
