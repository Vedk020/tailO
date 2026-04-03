import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/colors.dart';
import '../../../core/services/data_service.dart';
import '../../../core/widgets/brand_footer.dart';
import '../../auth/signup/signup_flow.dart';
import '../../reminders/reminders_page.dart';
import 'widgets/device_scanner_sheet.dart';
import 'widgets/live_map_card.dart'; // ✅ Import the real map card

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  // ✅ Map state
  late final MapController _mapController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _pairDevice(String petId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DeviceScannerSheet(petId: petId),
    );
  }

  // ✅ Refresh: re-fetch owner position and recenter map
  Future<void> _refreshLocation() async {
    setState(() => _isRefreshing = true);
    await DataService().refreshOwnerPosition();
    final pet = DataService().activePet;
    if (pet.lat != 0.0 && pet.lng != 0.0) {
      _mapController.move(LatLng(pet.lat, pet.lng), 15.0);
    }
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  child: const Icon(
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

        // ✅ Build pet location — fallback to 0,0 if no GPS yet
        final petLocation = LatLng(
          activePet.lat != 0.0 ? activePet.lat : 0.0001,
          activePet.lng != 0.0 ? activePet.lng : 0.0001,
        );
        final hasGps = activePet.isConnected && activePet.lat != 0.0;

        // ✅ Distance from DataService
        final distanceMeters = DataService().calculateDistance(
          activePet.lat,
          activePet.lng,
        );

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
                      ...pets.map(
                        (pet) => Padding(
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
                        ),
                      ),
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
                                        .withOpacity(0.1),
                                    alignment: Alignment.center,
                                    child: ElevatedButton.icon(
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
                                        backgroundColor: TailOColors.coral,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor: TailOColors.coral
                                            .withOpacity(0.5),
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
                    // ✅ REAL LIVE MAP CARD
                    LiveMapCard(
                      activePet: activePet,
                      petLocation: petLocation,
                      isLiveLocation: hasGps,
                      isRefreshing: _isRefreshing,
                      mapController: _mapController,
                      distanceMeters: distanceMeters,
                      onRefreshLocation: _refreshLocation,
                      onGetDirections: () => DataService().navigateToPet(
                        activePet.lat,
                        activePet.lng,
                      ),
                      onShareLocation: () => DataService().sharePetLocation(
                        activePet.lat,
                        activePet.lng,
                        activePet.name,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ================= REMINDERS CARD =================
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RemindersPage(),
                        ),
                      ),
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
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child:
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: DataService().remindersNotifier,
                              builder: (context, reminders, _) {
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
                                        const Icon(
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
                      : theme.cardColor.withOpacity(0.5),
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
              widthFactor: battery.clamp(0.0, 1.0),
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
          "${(battery * 100).round()}%",
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
