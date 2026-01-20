import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Core
import '../../../../core/theme/colors.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/brand_footer.dart';

// Features
import '../../auth/login/login_page.dart';
import '../../auth/signup/signup_flow.dart';

// Local Components
import 'widgets/id_card.dart';
import 'widgets/owner_card.dart';
import 'widgets/pet_switcher_sheet.dart';
import 'profile_share_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey _cardKey = GlobalKey();

  // --- SHARE OVERLAY LOGIC ---
  void _showShareOverlay(BuildContext context, dynamic pet) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Share",
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sharing Agent Identity",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    RepaintBoundary(
                      key: _cardKey,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: AgentIdCard(pet: pet, isInteractive: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 220,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => ProfileShareService.captureAndShare(
                          _cardKey,
                          pet.name,
                        ),
                        icon: const Icon(
                          LucideIcons.share2,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Share ID Card",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TailOColors.coral,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ✅ Replaced hardcoded check with getter
    final bool isGuest = DataService().isLoggedIn == false;

    if (isGuest) return _buildGuestMode(theme);

    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, selectedId, _) {
        final pets = DataService().pets;
        if (pets.isEmpty) return _buildEmptyState(theme);

        final currentPet = DataService().activePet;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Agent ID Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active Agent",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Text(
                    "Hold card to share",
                    style: TextStyle(fontSize: 12, color: TailOColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onLongPress: () => _showShareOverlay(context, currentPet),
                child: Hero(
                  tag: "id_card_${currentPet.id}",
                  child: AgentIdCard(pet: currentPet),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Switcher Button
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (ctx) => const PetSwitcherSheet(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: TailOColors.coral,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: TailOColors.coral.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.arrowLeftRight,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Switch Agent",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 3. Parent Card
              Text(
                "Agent Parent",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              const OwnerCard(),

              const SizedBox(height: 32),

              // 4. Settings & Actions
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),

              if (currentPet.isConnected) ...[
                _buildActionTile(
                  context,
                  icon: LucideIcons.unlink,
                  color: Colors.orange,
                  label: "Unpair Device",
                  onTap: () async {
                    await DataService().setPetConnection(currentPet.id, false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Device Unpaired"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],

              _buildActionTile(
                context,
                icon: LucideIcons.logOut,
                color: Colors.red,
                label: "Logout",
                onTap: () async {
                  await DataService().logout();
                  // Main.dart reactive listener will handle navigation
                },
              ),

              const SizedBox(height: 30),
              const BrandFooter(),
            ],
          ),
        );
      },
    );
  }

  // --- REUSABLE ACTION TILE ---
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- EMPTY / GUEST STATES ---
  Widget _buildGuestMode(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.lock, size: 60, color: TailOColors.muted),
            const SizedBox(height: 32),
            Text(
              "Unlock Full Access",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Sign in to manage your agents.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: TailOColors.muted),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TailOColors.coral,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text(
                "Log In",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.user, size: 60, color: TailOColors.muted),
          const SizedBox(height: 24),
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SignupFlow(isAddingAnotherPet: true),
              ),
            ),
            icon: const Icon(LucideIcons.plus, color: Colors.white),
            label: const Text(
              "Add Your First Agent",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: TailOColors.coral),
          ),
        ],
      ),
    );
  }
}
