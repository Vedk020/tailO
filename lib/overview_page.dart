import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart'; // REQUIRED: Add flutter_map to pubspec.yaml
import 'package:latlong2/latlong.dart'; // REQUIRED: Add latlong2 to pubspec.yaml
import 'package:geolocator/geolocator.dart'; // REQUIRED: Add geolocator to pubspec.yaml
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
  bool _isPairing = false; // Local state for pairing loading
  bool _isRefreshingLocation = false; // Local state for location refresh

  // Map Controller to move the map programmatically
  final MapController _mapController = MapController();

  // DEFAULT LOCATION: Amaravati/Guntur Region (Fallback if GPS fails)
  LatLng _petLocation = const LatLng(16.4971, 80.4992);
  bool _isLiveLocation = false;

  @override
  void initState() {
    super.initState();
    // Attempt to fetch real GPS immediately on load
    _getCurrentLocation();
  }

  // --- GET REAL LOCATION LOGIC ---
  Future<void> _getCurrentLocation() async {
    setState(() => _isRefreshingLocation = true); // Start loading spinner

    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() => _isRefreshingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    // 2. Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() => _isRefreshingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() => _isRefreshingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied. Please enable in settings.',
            ),
          ),
        );
      }
      return;
    }

    // 3. Get Actual Position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _petLocation = LatLng(position.latitude, position.longitude);
          _isLiveLocation = true;
          _isRefreshingLocation = false; // Stop loading
        });

        // Animated move to real location
        _mapController.move(_petLocation, 16.0);

        // Success Feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location Updated"),
            duration: Duration(milliseconds: 800),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
      if (mounted) setState(() => _isRefreshingLocation = false);
    }
  }

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

  // --- PLACEHOLDER NAVIGATION ---
  void _getDirections() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Opening Maps... (Directions coming soon!)"),
        backgroundColor: TailOColors.coral,
      ),
    );
    // TODO: Implement url_launcher to open Google Maps
    // final url = 'https://www.google.com/maps/dir/?api=1&destination=${_petLocation.latitude},${_petLocation.longitude}';
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
                          // 1. The Belt Image
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
                            "Updated just now",
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

              const SizedBox(height: 30),

              // ================= LIVE MAP WIDGET =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // REAL LIVE MAP CONTAINER
                    Container(
                      height: 220, // Taller to accommodate controls
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // 1. FLUTTER MAP IMPLEMENTATION
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _petLocation,
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags:
                                      InteractiveFlag.all &
                                      ~InteractiveFlag.rotate,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  // CartoDB tiles: Auto Dark/Light mode
                                  urlTemplate: isDark
                                      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                                      : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  userAgentPackageName:
                                      'com.aurorallabs.tailo', // CORRECT PACKAGE NAME
                                ),
                                // 2. PET MARKER
                                MarkerLayer(
                                  markers: [
                                    if (activePet.isConnected)
                                      Marker(
                                        point: _petLocation,
                                        width: 80,
                                        height: 80,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Outer pulsing ring effect
                                            Container(
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: TailOColors.coral
                                                      .withValues(alpha: 0.3),
                                                  width: 1.5,
                                                ),
                                                color: TailOColors.coral
                                                    .withValues(alpha: 0.1),
                                              ),
                                            ),
                                            // The Avatar
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
                                                    color: TailOColors.coral
                                                        .withValues(alpha: 0.6),
                                                    blurRadius: 16,
                                                    spreadRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    theme.cardColor,
                                                backgroundImage:
                                                    DataService.getImageProvider(
                                                      activePet.image,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),

                            // 3. OVERLAYS (Gradient for text readability)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 80,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      theme.cardColor.withValues(alpha: 0.95),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 4. "Live Location" Label
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: activePet.isConnected
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.radio,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          activePet.isConnected
                                              ? "LIVE"
                                              : "OFFLINE",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _isLiveLocation
                                        ? "Current Location"
                                        : "Last Known Loc",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 5. MAP CONTROLS (Top Right)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Column(
                                children: [
                                  // Expand Button
                                  _buildMapControlButton(
                                    context,
                                    icon: LucideIcons.maximize,
                                    onTap: () {
                                      // Navigate to Full Screen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FullScreenMapPage(
                                            petImage: activePet.image,
                                            initialLocation: _petLocation,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Refresh Button
                                  _buildMapControlButton(
                                    context,
                                    icon: LucideIcons.refreshCw,
                                    isLoading: _isRefreshingLocation,
                                    onTap: _getCurrentLocation,
                                  ),
                                ],
                              ),
                            ),

                            // 6. GET DIRECTIONS BUTTON (Bottom Right)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton.small(
                                backgroundColor: TailOColors.coral,
                                onPressed: _getDirections,
                                tooltip: "Get Directions",
                                child: const Icon(
                                  LucideIcons.navigation,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  // --- HELPER FOR MAP BUTTONS ---
  Widget _buildMapControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TailOColors.coral,
              ),
            )
          : IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(icon, size: 20, color: theme.iconTheme.color),
              onPressed: onTap,
            ),
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
                  // UPDATED: Use DataService for images
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

// --- FULL SCREEN MAP PAGE ---
class FullScreenMapPage extends StatefulWidget {
  final String petImage;
  final LatLng initialLocation;

  const FullScreenMapPage({
    super.key,
    required this.petImage,
    required this.initialLocation,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage> {
  late final MapController _mapController;
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocation = widget.initialLocation;
  }

  void _recenter() {
    _mapController.move(_currentLocation, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                    : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.aurorallabs.tailo',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TailOColors.coral.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            color: TailOColors.coral.withValues(alpha: 0.15),
                          ),
                        ),
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TailOColors.coral,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: TailOColors.coral.withValues(alpha: 0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundImage: DataService.getImageProvider(
                              widget.petImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Icon(
                  LucideIcons.arrowLeft,
                  color: theme.iconTheme.color,
                ),
              ),
            ),
          ),

          // Recenter Button
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: TailOColors.coral,
              onPressed: _recenter,
              child: const Icon(LucideIcons.locate, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
