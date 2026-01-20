import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/data_service.dart';
import '../../../../data/models/pet_model.dart';

class AgentIdCard extends StatelessWidget {
  final Pet pet;
  final bool isInteractive;

  const AgentIdCard({super.key, required this.pet, this.isInteractive = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final bool isJojo = pet.name.trim().toLowerCase() == 'jojo';
    final String displayId = isJojo ? '007' : pet.id;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Icon
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              LucideIcons.dog,
              size: 150,
              color: theme.dividerColor.withValues(alpha: 0.05),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: TailOColors.coral, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        backgroundImage: DataService.getImageProvider(
                          pet.image,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Name & Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            pet.name,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: TailOColors.coral,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "OFFICIAL ID",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Logo & ID Number
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "tail",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: theme.textTheme.bodyLarge?.color,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Text(
                              "O",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: TailOColors.coral,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "ID NUMBER",
                          style: TextStyle(
                            fontSize: 10,
                            color: TailOColors.muted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          displayId,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(color: theme.dividerColor, thickness: 1),
                const SizedBox(height: 24),

                // Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(context, "Breed", pet.breed),
                    _buildDetailItem(context, "Gender", pet.gender),
                    // Note: pet.age getter needs to be in model, or calculate here:
                    _buildDetailItem(context, "Age", _calculateAge(pet.dob)),
                    _buildDetailItem(context, "Weight", "${pet.weight} kg"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(DateTime dob) {
    final now = DateTime.now();
    final difference = now.difference(dob);
    final years = (difference.inDays / 365).floor();
    if (years > 0) return "$years yrs";
    final months = (difference.inDays / 30).floor();
    return "$months mos";
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: TailOColors.muted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
