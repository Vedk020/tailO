import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'data_service.dart';
import 'signup_flow.dart';
import 'reminders_page.dart';
import 'brand_footer.dart'; // Ensure this is imported

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool _isPairing = false; // Local state for loading spinner

  // --- SIMULATE PAIRING ---
  void _pairDevice(String petId) async {
    setState(() => _isPairing = true);

    // Fake delay for "Searching..."
    await Future.delayed(const Duration(seconds: 2));

    // Update Data
    await DataService().setPetConnection(petId, true);

    setState(() => _isPairing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("TailO Belt Connected Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen to Global Pet ID Changes
    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, selectedId, _) {
        final pets = DataService().pets;

        // --- EMPTY STATE ---
        if (pets.isEmpty) {
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
                  child: Icon(
                    LucideIcons.dog,
                    size: 60,
                    color: TailOColors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No Agents yet! 🤫",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Add an agent to start tracking their health.",
                  style: TextStyle(color: TailOColors.muted),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SignupFlow(isAddingAnotherPet: true),
                      ),
                    ).then((_) => setState(() {}));
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // --- NORMAL STATE ---
        final activePet = DataService().activePet;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= PET LIST =================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...pets.map((pet) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: _buildPetAvatar(
                            context,
                            pet.image,
                            pet.name,
                            pet.id,
                            isSelected: pet.id == activePet.id,
                            isConnected: pet.isConnected,
                            onTap: () => DataService().switchPet(pet.id),
                          ),
                        );
                      }),
                      _buildAddPetButton(context),
                    ],
                  ),
                ),
              ),

              // ================= HERO DEVICE SECTION =================
              Container(
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
                          // 1. The Belt Image (Static Asset)
                          Positioned(
                            bottom: 0,
                            child: Image.asset(
                              'assets/images/belt.png',
                              fit: BoxFit.contain,
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.85,
                            ),
                          ),

                          // 2. BLUR OVERLAY (Only if Disconnected)
                          if (!activePet.isConnected)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 4,
                                    sigmaY: 4,
                                  ),
                                  child: Container(
                                    color: theme.scaffoldBackgroundColor
                                        .withValues(alpha: 0.1),
                                    alignment: Alignment.center,
                                    child: _isPairing
                                        // Loading State
                                        ? Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
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
                                        // Pair Button
                                        : ElevatedButton.icon(
                                            onPressed: () =>
                                                _pairDevice(activePet.id),
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
                                              backgroundColor:
                                                  TailOColors.coral,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              elevation: 8,
                                              shadowColor: TailOColors.coral
                                                  .withValues(alpha: 0.5),
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
                          BatteryIndicator(battery: activePet.battery),
                          const SizedBox(height: 6),
                          const Text(
                            "Updated 2 min ago",
                            style: TextStyle(
                              color: Color(0xFF4A4A4E),
                              fontSize: 11,
                            ),
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
              ),

              // ================= CONTENT SECTION =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Live Location Map
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.4 : 0.1,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                image: DecorationImage(
                                  image: const NetworkImage(
                                    "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/World_map_blank_without_borders.svg/2000px-World_map_blank_without_borders.svg.png",
                                  ),
                                  fit: BoxFit.cover,
                                  opacity: 0.3,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withValues(
                                      alpha: isDark ? 0.5 : 0.2,
                                    ),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (activePet.isConnected)
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: TailOColors.coral.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: TailOColors.coral,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: TailOColors.coral.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 16,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    // UPDATED: Use DataService to load pet image correctly
                                    backgroundImage:
                                        DataService.getImageProvider(
                                          activePet.image,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            bottom: 14,
                            left: 16,
                            child: Text(
                              "Live Location",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFAAAAAE),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ================= DYNAMIC REMINDERS CARD =================
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RemindersPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 0.5,
                          ),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child:
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: DataService().remindersNotifier,
                              builder: (context, reminders, _) {
                                // Filter: Top 3 active reminders
                                final active = reminders
                                    .where((r) => !r['isCompleted'])
                                    .take(3)
                                    .toList();

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Upcoming Reminders",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: theme
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                        ),
                                        Icon(
                                          LucideIcons.chevronRight,
                                          size: 20,
                                          color: TailOColors.muted,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    if (active.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          "No upcoming reminders",
                                          style: TextStyle(
                                            color: TailOColors.muted,
                                          ),
                                        ),
                                      )
                                    else
                                      ...active.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final r = entry.value;
                                        return Column(
                                          children: [
                                            if (index > 0) _divider(context),
                                            _buildReminderItem(
                                              context,
                                              r['icon'],
                                              r['title'],
                                              r['time'],
                                            ),
                                          ],
                                        );
                                      }),
                                  ],
                                );
                              },
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- ADD FOOTER HERE ---
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: BrandFooter(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Divider(
        color: Theme.of(context).dividerColor,
        height: 1,
        thickness: 0.5,
      ),
    );
  }

  Widget _buildPetAvatar(
    BuildContext context,
    String assetPath,
    String name,
    String id, {
    required bool isSelected,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final Color dotColor = isConnected
        ? const Color(0xFF34C759)
        : TailOColors.muted;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: TailOColors.coral, width: 2.5)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: isSelected
                      ? theme.cardColor
                      : theme.cardColor.withValues(alpha: 0.5),
                  // UPDATED: Use DataService to load image correctly
                  backgroundImage: DataService.getImageProvider(assetPath),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? theme.textTheme.bodyLarge?.color
                  : TailOColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SignupFlow(isAddingAnotherPet: true),
          ),
        ).then((_) => setState(() {}));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TailOColors.muted, width: 1.5),
            ),
            child: const Icon(
              LucideIcons.plus,
              color: TailOColors.muted,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Add",
            style: TextStyle(
              fontSize: 11,
              color: TailOColors.muted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    IconData icon,
    String title,
    String time,
  ) {
    return Row(
      children: [
        Icon(icon, color: TailOColors.coral, size: 20),
        const SizedBox(width: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Spacer(),
        Text(
          "— $time",
          style: const TextStyle(
            color: TailOColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class BatteryIndicator extends StatelessWidget {
  final double battery;
  const BatteryIndicator({super.key, required this.battery});

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
