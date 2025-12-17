import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'theme.dart';
import 'data_service.dart';
import 'signup_flow.dart';
import 'login_page.dart';
import 'pet_model.dart';
import 'owner_qr_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey _cardKey = GlobalKey();

  // --- SHARE LOGIC (Hidden for brevity, same as before) ---
  void _showShareOverlay(BuildContext context, Pet pet) {
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
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    RepaintBoundary(
                      key: _cardKey,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildHeroIDCard(
                            context,
                            pet,
                            isInteractive: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 50, end: 0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(0, value),
                        child: child,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 220,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () => _captureAndShare(pet.name),
                              icon: const Icon(
                                LucideIcons.share2,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Share ID Card",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TailOColors.coral,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 10,
                                shadowColor: TailOColors.coral.withValues(
                                  alpha: 0.5,
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
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureAndShare(String petName) async {
    try {
      RenderRepaintBoundary? boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/tailo_id_${petName}.png',
      ).create();
      await imagePath.writeAsBytes(pngBytes);
      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Meet Agent $petName! 🐾 Tracked securely via TailO.');
    } catch (e) {
      debugPrint("Error capturing screenshot: $e");
    }
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isGuest = DataService().ownerEmail == "guest@tailo.com";

    if (isGuest) return _buildGuestMode(theme);

    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, selectedId, _) {
        final pets = DataService().pets;
        if (pets.isEmpty) return _buildEmptyState(theme);
        final currentPet = DataService().activePet;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
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

                // Active Agent
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
                    child: _buildHeroIDCard(context, currentPet),
                  ),
                ),

                const SizedBox(height: 24),

                // Switch Button
                GestureDetector(
                  onTap: () => _showPetSwitcher(context),
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

                // Parent
                Text(
                  "Agent Parent",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOwnerCard(context),

                const SizedBox(height: 32),

                // Settings
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),

                // Logout Button (Unpair Removed)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await DataService().logout();
                      if (context.mounted)
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.logOut, color: Colors.red, size: 22),
                        SizedBox(width: 12),
                        Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // --- FOOTER BRANDING (RAPIDO STYLE) ---
                Align(
                  alignment: Alignment.centerLeft, // Left aligned like image
                  child: Opacity(
                    opacity: 0.4, // Subtle watermark look
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#AuroralLabs",
                          style: TextStyle(
                            fontSize: 40, // Large bold font
                            fontWeight: FontWeight.w900,
                            color: theme.dividerColor.withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Flag Icon (Using text emoji or an asset if you have one)
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
                            const Icon(
                              LucideIcons.heart,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Crafted by love",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.heart,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "for your loved once",
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- SUB-WIDGETS ---
  // (All sub-widgets: _buildGuestMode, _buildEmptyState, _showPetSwitcher, _buildHeroIDCard, _buildOwnerCard remain exactly the same as previous)

  Widget _buildGuestMode(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Image.asset(
                'assets/images/appLogo.png',
                height: 60,
                width: 60,
              ),
            ),
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
              "Sign in to manage your agents, sync data across devices, and access premium features.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: TailOColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TailOColors.coral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SignupFlow(isAddingAnotherPet: false),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.user, size: 60, color: TailOColors.muted),
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildOwnerCard(context),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SignupFlow(isAddingAnotherPet: true),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus, color: Colors.white),
            label: const Text(
              "Add Your First Agent",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: TailOColors.coral,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPetSwitcher(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final pets = DataService().pets;
            final activeId = DataService().activePet.id;
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: TailOColors.muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Switch Agent",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.plus,
                          color: TailOColors.coral,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SignupFlow(isAddingAnotherPet: true),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (pets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No agents found.",
                        style: TextStyle(color: TailOColors.muted),
                      ),
                    )
                  else
                    ...pets.map((pet) {
                      final isSelected = pet.id == activeId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TailOColors.coral.withValues(alpha: 0.1)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? TailOColors.coral
                                  : theme.dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    DataService().switchPet(pet.id);
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage: AssetImage(pet.image),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pet.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: theme
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          Text(
                                            pet.breed,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: TailOColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await DataService().removePet(pet.id);
                                  setSheetState(() {});
                                  if (DataService().pets.isEmpty &&
                                      context.mounted)
                                    Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroIDCard(
    BuildContext context,
    Pet pet, {
    bool isInteractive = true,
  }) {
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: TailOColors.coral, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        backgroundImage: AssetImage(pet.image),
                      ),
                    ),
                    const SizedBox(width: 20),
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
                            Text(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _idDetailItem(context, "Breed", pet.breed),
                    _idDetailItem(context, "Gender", pet.gender),
                    _idDetailItem(context, "Age", pet.age),
                    _idDetailItem(context, "Weight", pet.weight),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _idDetailItem(BuildContext context, String label, String value) {
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

  Widget _buildOwnerCard(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final ownerName = DataService().ownerName;
    final ownerEmail = DataService().ownerEmail;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OwnerQrPage()),
      ),
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
            const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/images/pfp.jpeg'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ownerName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ownerEmail,
                    style: TextStyle(fontSize: 14, color: TailOColors.muted),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "+91 9885085343",
                    style: TextStyle(fontSize: 14, color: TailOColors.muted),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(LucideIcons.qrCode, color: TailOColors.coral, size: 24),
                const SizedBox(height: 4),
                const Icon(
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
