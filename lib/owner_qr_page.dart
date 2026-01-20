import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/services/data_service.dart';
import '../../core/theme/colors.dart';

class OwnerQrPage extends StatelessWidget {
  const OwnerQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ✅ Generate safe data (No password)
    final qrData = jsonEncode({
      "username": DataService().ownerEmail,
      "type": "tailO_profile_share",
      "timestamp": DateTime.now().toIso8601String(),
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Scan to connect",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
