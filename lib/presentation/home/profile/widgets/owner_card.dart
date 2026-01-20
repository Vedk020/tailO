import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/data_service.dart';
import '../../../../../owner_qr_page.dart';

class OwnerCard extends StatelessWidget {
  const OwnerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final dataService = DataService();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnerQrPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: DataService.getImageProvider(
                dataService.ownerImage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataService.ownerName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dataService.ownerEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: TailOColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // If you have phone in DataService, use it. Else hide or use "Contact Info"
                  const Text(
                    "Tap for QR Code",
                    style: TextStyle(
                      fontSize: 12,
                      color: TailOColors.coral,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Column(
              children: [
                Icon(LucideIcons.qrCode, color: TailOColors.coral, size: 24),
                SizedBox(height: 4),
                Icon(
                  LucideIcons.chevronRight,
                  color: TailOColors.muted,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
