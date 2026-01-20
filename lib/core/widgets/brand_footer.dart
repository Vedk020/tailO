import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_config.dart'; // Import Config

class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6);
    final watermarkColor = theme.dividerColor.withValues(alpha: 0.8);

    return Column(
      children: [
        const SizedBox(height: 60), // Top spacing
        Align(
          alignment: Alignment.centerLeft,
          child: Opacity(
            opacity: 0.5, // Subtle Watermark style
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. COMPANY WATERMARK
                Text(
                  AppConfig.brandTagline,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: watermarkColor,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -1.0,
                  ),
                ),

                const SizedBox(height: 12),

                // 2. MADE FOR LABEL
                Row(
                  children: [
                    Text(
                      "${AppConfig.madeInEmoji} ",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      AppConfig.madeInLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 3. CRAFTED LINE
                Row(
                  children: [
                    const Icon(LucideIcons.heart, size: 14, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      AppConfig.craftedWith,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 4. LOVED ONES LINE
                Row(
                  children: [
                    const Icon(LucideIcons.heart, size: 14, color: Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      AppConfig.forLovedOnes,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                // 5. VERSION INFO (Optional, good for debug)
                const SizedBox(height: 16),
                Text(
                  "${AppConfig.appName} ${AppConfig.version} (${AppConfig.buildNumber})",
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.disabledColor,
                    fontWeight: FontWeight.w500,
                  ),
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
