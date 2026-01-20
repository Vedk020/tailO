import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/services/data_service.dart';
import '../../core/theme/theme_controller.dart';

// Navigation Targets
import '../auth/login/login_page.dart';
import '../home/profile/profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ThemeController.isDark;

    // Listen to Pet State for "Unpair" visibility
    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, selectedId, _) {
        final currentPet = DataService().activePet;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              "Settings",
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ACCOUNT SECTION ---
                const _SectionHeader("Account"),
                _SettingsTile(
                  icon: LucideIcons.user,
                  title: "Profile",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: LucideIcons.dog,
                  title: "Pets & Devices",
                  onTap: () {
                    // Navigate to ProfilePage which handles Pet Switching
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),

                // UNPAIR BUTTON (Conditional)
                if (currentPet.isConnected) ...[
                  const SizedBox(height: 12),
                  _UnpairTile(petId: currentPet.id),
                ],

                const SizedBox(height: 28),

                // --- APP SECTION ---
                const _SectionHeader("App"),
                _ThemeToggleTile(isDark: isDark),

                const SizedBox(height: 28),

                // --- SECURITY SECTION ---
                const _SectionHeader("Security"),
                _SettingsTile(
                  icon: LucideIcons.lock,
                  title: "Privacy & Security",
                  onTap: () => _showPlaceholder(context, "Privacy Settings"),
                ),

                const SizedBox(height: 28),

                // --- ABOUT SECTION ---
                const _SectionHeader("About"),
                _SettingsTile(
                  icon: LucideIcons.info,
                  title: "About tailO",
                  onTap: () => _showPlaceholder(context, "App Info"),
                ),

                const SizedBox(height: 12),

                // --- LOGOUT ---
                _SettingsTile(
                  icon: LucideIcons.logOut,
                  title: "Logout",
                  isDestructive: true,
                  onTap: () => _handleLogout(context),
                ),

                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "v1.0.0 (Build 2024)",
                    style: TextStyle(
                      color: TailOColors.muted.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    // Show confirmation dialog could go here
    await DataService().logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature coming soon!"),
        backgroundColor: TailOColors.muted,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ------------------------------------------------------
// 🧩 REUSABLE SETTINGS WIDGETS
// ------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: TailOColors.muted,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? TailOColors.error
        : theme.textTheme.bodyLarge?.color;
    final iconColor = isDestructive ? TailOColors.error : TailOColors.coral;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDestructive
                  ? TailOColors.error.withValues(alpha: 0.3)
                  : theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? TailOColors.error.withValues(alpha: 0.1)
                      : TailOColors.coral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleTile({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TailOColors.coral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? LucideIcons.moon : LucideIcons.sun,
              color: TailOColors.coral,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Dark Mode",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Switch.adaptive(
            value: isDark,
            activeColor: TailOColors.coral,
            onChanged: (value) => ThemeController.toggleTheme(value),
          ),
        ],
      ),
    );
  }
}

class _UnpairTile extends StatelessWidget {
  final String petId;
  const _UnpairTile({required this.petId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await DataService().setPetConnection(petId, false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Device Unpaired Successfully"),
                backgroundColor: TailOColors.warning,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TailOColors.warning.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TailOColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.unlink,
                  color: TailOColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Unpair Device",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: TailOColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
