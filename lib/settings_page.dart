import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'theme_controller.dart';
import 'data_service.dart';
import 'login_page.dart'; // Required for Logout navigation

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeController.isDark;

    // Listen to changes in pet selection/connection status
    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, selectedId, _) {
        final currentPet = DataService().activePet;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          LucideIcons.chevronLeft,
                          color: theme.iconTheme.color,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle("Account"),
                  _buildSettingsItem(
                    context,
                    LucideIcons.user,
                    "Profile",
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    context,
                    LucideIcons.dog,
                    "Pets & Devices",
                    onTap: () {},
                  ),

                  // UNPAIR BUTTON (Only if connected)
                  if (currentPet.isConnected) ...[
                    const SizedBox(height: 12),
                    _buildUnpairButton(context, currentPet.id),
                  ],

                  const SizedBox(height: 28),

                  _sectionTitle("App"),
                  _buildThemeToggle(context, isDark),

                  const SizedBox(height: 28),

                  _sectionTitle("Security"),
                  _buildSettingsItem(
                    context,
                    LucideIcons.lock,
                    "Privacy & Security",
                    onTap: () {},
                  ),

                  const SizedBox(height: 28),

                  _sectionTitle("About"),
                  _buildSettingsItem(
                    context,
                    LucideIcons.info,
                    "About tailO",
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  // LOGOUT ITEM
                  _buildSettingsItem(
                    context,
                    LucideIcons.logOut,
                    "Logout",
                    isDestructive: true,
                    onTap: () async {
                      await DataService().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            if (theme.brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isDark ? LucideIcons.moon : LucideIcons.sun,
              color: TailOColors.coral,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "Dark Mode",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Switch(
              value: isDark,
              activeColor: TailOColors.coral,
              onChanged: (value) {
                ThemeController.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: TailOColors.muted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.textTheme.bodyLarge?.color;
    final iconColor = isDestructive ? Colors.red : TailOColors.coral;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.3)
                    : theme.dividerColor,
              ),
              boxShadow: [
                if (theme.brightness == Brightness.light)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: color,
                    ),
                  ),
                ),
                if (!isDestructive)
                  Icon(
                    LucideIcons.chevronRight,
                    color: theme.iconTheme.color,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnpairButton(BuildContext context, String petId) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Unpair Logic
          await DataService().setPetConnection(petId, false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Device Unpaired Successfully"),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
          ),
          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align left like others
            children: [
              Icon(LucideIcons.unlink, color: Colors.orange, size: 22),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  "Unpair Device",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ),
              Icon(LucideIcons.chevronRight, color: Colors.orange, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
