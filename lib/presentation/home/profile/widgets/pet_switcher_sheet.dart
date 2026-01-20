import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/data_service.dart';
import '../../../../presentation/auth/signup/signup_flow.dart';

class PetSwitcherSheet extends StatefulWidget {
  const PetSwitcherSheet({super.key});

  @override
  State<PetSwitcherSheet> createState() => _PetSwitcherSheetState();
}

class _PetSwitcherSheetState extends State<PetSwitcherSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pets = DataService().pets;
    final activeId = DataService().activePet.id;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: TailOColors.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Switch Agent",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plus, color: TailOColors.coral),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SignupFlow(isAddingAnotherPet: true),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // List
          if (pets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No agents found.",
                style: TextStyle(color: TailOColors.muted),
              ),
            )
          else
            ...pets.map((pet) {
              final isSelected = pet.id == activeId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TailOColors.coral.withValues(alpha: 0.1)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? TailOColors.coral
                          : theme.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            DataService().switchPet(pet.id);
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: DataService.getImageProvider(
                                  pet.image,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  Text(
                                    pet.breed,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: TailOColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.trash2,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () async {
                          await DataService().removePet(pet.id);
                          setState(() {}); // Refresh local state
                          if (DataService().pets.isEmpty && mounted)
                            Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
