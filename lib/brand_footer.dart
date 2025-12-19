import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 60), // Top spacing
        Align(
          alignment: Alignment.centerLeft,
          child: Opacity(
            opacity: 0.4, // Watermark style
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "#AuroralLabs",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: theme.dividerColor.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("🇮🇳 ", style: TextStyle(fontSize: 14)),
                    Text(
                      "Made for India",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.heart, size: 14, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      "Crafted with love",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                // Optional second line if you want to keep the "loved ones" part
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.heart, size: 14, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      "for your loved ones",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40), // Bottom spacing
      ],
    );
  }
}
