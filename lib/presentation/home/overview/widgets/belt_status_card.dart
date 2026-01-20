import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/pet_model.dart';
import '../../../../core/theme/colors.dart';

class BeltStatusCard extends StatelessWidget {
  final Pet activePet;
  final bool isPairing;
  final Function(String) onPair;

  const BeltStatusCard({
    super.key,
    required this.activePet,
    required this.isPairing,
    required this.onPair,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      child: Column(
        children: [
          // DEVICE IMAGE CONTAINER
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/belt.png',
                    fit: BoxFit.contain,
                    height: 200,
                    width: MediaQuery.of(context).size.width * 0.85,
                  ),
                ),

                // BLUR OVERLAY (If Disconnected)
                if (!activePet.isConnected)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          color: theme.scaffoldBackgroundColor.withValues(
                            alpha: 0.1,
                          ),
                          alignment: Alignment.center,
                          child: isPairing
                              ? Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Searching...",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: () => onPair(activePet.id),
                                  icon: const Icon(
                                    LucideIcons.bluetooth,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Pair Device",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TailOColors.coral,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 8,
                                    shadowColor: TailOColors.coral.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "TailO Belt · ${activePet.name}",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              const SizedBox(height: 10),
              if (activePet.isConnected) ...[
                _BatteryIndicator(battery: activePet.battery),
                const SizedBox(height: 6),
                const Text(
                  "Updated just now",
                  style: TextStyle(color: Color(0xFF4A4A4E), fontSize: 11),
                ),
              ] else ...[
                const Text(
                  "Device Disconnected",
                  style: TextStyle(
                    color: TailOColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  final double battery;
  const _BatteryIndicator({required this.battery});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Column(
      children: [
        Container(
          width: 70,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: battery,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${(battery * 100).round()} %",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
