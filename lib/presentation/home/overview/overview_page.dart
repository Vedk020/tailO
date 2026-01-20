import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // REQUIRED
import 'package:latlong2/latlong.dart'; // REQUIRED
import 'package:geolocator/geolocator.dart'; // REQUIRED
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/data_service.dart';
import '../../auth/signup/signup_flow.dart';
import '../../../../core/widgets/brand_footer.dart'; // From core/widgets
import '../../../../core/theme/colors.dart';
// Import Local Widgets
import 'widgets/pet_list_card.dart';
import 'widgets/belt_status_card.dart';
import 'widgets/live_map_card.dart';
import 'widgets/reminders_preview_card.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool _isPairing = false;
  bool _isRefreshingLocation = false;
  final MapController _mapController = MapController();
  LatLng _petLocation = const LatLng(16.4971, 80.4992);
  bool _isLiveLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isRefreshingLocation = true);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isRefreshingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isRefreshingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isRefreshingLocation = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _petLocation = LatLng(position.latitude, position.longitude);
          _isLiveLocation = true;
          _isRefreshingLocation = false;
        });
        _mapController.move(_petLocation, 16.0);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location Updated"),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isRefreshingLocation = false);
    }
  }

  void _pairDevice(String petId) async {
    setState(() => _isPairing = true);
    await Future.delayed(const Duration(seconds: 2));
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

  void _getDirections() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Opening Maps... (Directions coming soon!)"),
        backgroundColor: TailOColors.coral,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<String?>(
      valueListenable: DataService().selectedPetIdNotifier,
      builder: (context, selectedId, _) {
        final pets = DataService().pets;

        // EMPTY STATE
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
                    );
                  },
                  icon: const Icon(LucideIcons.plus, color: Colors.white),
                  label: const Text("Add Your First Agent"),
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

        final activePet = DataService().activePet;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PET LIST
              PetListCard(pets: pets, activePet: activePet),

              // 2. BELT STATUS
              BeltStatusCard(
                activePet: activePet,
                isPairing: _isPairing,
                onPair: _pairDevice,
              ),

              const SizedBox(height: 30),

              // 3. LIVE MAP
              LiveMapCard(
                activePet: activePet,
                petLocation: _petLocation,
                isLiveLocation: _isLiveLocation,
                isRefreshing: _isRefreshingLocation,
                mapController: _mapController,
                onRefreshLocation: _getCurrentLocation,
                onGetDirections: _getDirections,
              ),

              const SizedBox(height: 16),

              // 4. REMINDERS
              const RemindersPreviewCard(),

              const SizedBox(height: 16),

              // 5. FOOTER
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: BrandFooter(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
