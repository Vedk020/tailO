import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/data_service.dart';
import '../../../../data/models/pet_model.dart';
import 'full_screen_map_page.dart';
import '../../../../core/theme/colors.dart';

class LiveMapCard extends StatelessWidget {
  final Pet activePet;
  final LatLng petLocation;
  final bool isLiveLocation;
  final bool isRefreshing;
  final MapController mapController;
  final VoidCallback onRefreshLocation;
  final VoidCallback onGetDirections;

  const LiveMapCard({
    super.key,
    required this.activePet,
    required this.petLocation,
    required this.isLiveLocation,
    required this.isRefreshing,
    required this.mapController,
    required this.onRefreshLocation,
    required this.onGetDirections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
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
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: petLocation,
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
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
                          if (activePet.isConnected)
                            Marker(
                              point: petLocation,
                              width: 80,
                              height: 80,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: TailOColors.coral.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1.5,
                                      ),
                                      color: TailOColors.coral.withValues(
                                        alpha: 0.1,
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
                                      backgroundColor: theme.cardColor,
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

                  // Map Overlay Gradient
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

                  // Live Status Label
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
                                activePet.isConnected ? "LIVE" : "OFFLINE",
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
                          isLiveLocation
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

                  // Map Controls (Top Right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Column(
                      children: [
                        _buildMapControlButton(
                          context,
                          icon: LucideIcons.maximize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenMapPage(
                                  petImage: activePet.image,
                                  initialLocation: petLocation,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildMapControlButton(
                          context,
                          icon: LucideIcons.refreshCw,
                          isLoading: isRefreshing,
                          onTap: onRefreshLocation,
                        ),
                      ],
                    ),
                  ),

                  // Get Directions (Bottom Right)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      backgroundColor: TailOColors.coral,
                      onPressed: onGetDirections,
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
        ],
      ),
    );
  }

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
}
