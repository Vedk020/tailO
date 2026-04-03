import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../data/models/pet_model.dart';
import '../../../../../core/services/data_service.dart'; // ✅ Import DataService

class BeltStatusCard extends StatelessWidget {
  final Pet pet;

  const BeltStatusCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = pet.isConnected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.activity,
                    color: theme.textTheme.bodyLarge?.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Collar Status",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),

              // ✅ MAKE THE STATUS CLICKABLE
              GestureDetector(
                onTap: () {
                  if (isConnected) {
                    DataService().disconnectHardware();
                  } else {
                    DataService().connectHardware();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Searching for Collar...")),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? TailOColors.success.withValues(alpha: 0.1)
                        : TailOColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? TailOColors.success
                              : TailOColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected
                            ? "Connected"
                            : "Tap to Connect", // Prompts the user to tap
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isConnected
                              ? TailOColors.success
                              : TailOColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Battery and Last Sync logic... (Keep your existing code here)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                LucideIcons.battery,
                "Battery",
                "${(pet.battery * 100).toInt()}%",
              ),
              _buildInfoItem(
                context,
                LucideIcons.refreshCw,
                "Last Sync",
                isConnected ? "Just now" : "2 hrs ago",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: TailOColors.muted, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: TailOColors.muted),
        ),
      ],
    );
  }
}
