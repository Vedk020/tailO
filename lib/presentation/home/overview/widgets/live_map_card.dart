import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  final double? distanceMeters; // ✅ nullable — null if owner GPS unavailable
  final VoidCallback onRefreshLocation;
  final VoidCallback onGetDirections;
  final VoidCallback onShareLocation; // ✅ new

  const LiveMapCard({
    super.key,
    required this.activePet,
    required this.petLocation,
    required this.isLiveLocation,
    required this.isRefreshing,
    required this.mapController,
    required this.distanceMeters,
    required this.onRefreshLocation,
    required this.onGetDirections,
    required this.onShareLocation,
  });

  // ✅ Formats distance nicely: "340 m" or "1.2 km"
  String _formatDistance(double? meters) {
    if (meters == null) return '--';
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasGps = activePet.isConnected && activePet.lat != 0.0;

    return Column(
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
                // ✅ Real map — only render if we have GPS
                if (hasGps)
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
                  )
                else
                  // ✅ Placeholder when no GPS yet
                  Container(
                    color: isDark
                        ? const Color(0xFF1C1C1E)
                        : const Color(0xFFF2F2F7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.mapPin,
                            size: 32,
                            color: TailOColors.muted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activePet.isConnected
                                ? "Acquiring GPS..."
                                : "Device Offline",
                            style: const TextStyle(
                              color: TailOColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bottom gradient overlay
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

                // ✅ Bottom left: status + distance
                Positioned(
                  bottom: 14,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          // ✅ Distance badge
                          if (distanceMeters != null ||
                              activePet.isConnected) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TailOColors.coral.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: TailOColors.coral.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.ruler,
                                    color: TailOColors.coral,
                                    size: 11,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDistance(distanceMeters),
                                    style: const TextStyle(
                                      color: TailOColors.coral,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLiveLocation ? "Current Location" : "Last Known Loc",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // Top right: expand + refresh
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _buildControlButton(
                        context,
                        icon: LucideIcons.maximize,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenMapPage(
                              petImage: activePet.image,
                              initialLocation: petLocation,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildControlButton(
                        context,
                        icon: LucideIcons.refreshCw,
                        isLoading: isRefreshing,
                        onTap: onRefreshLocation,
                      ),
                    ],
                  ),
                ),

                // Bottom right: navigate FAB
                Positioned(
                  bottom: 14,
                  right: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: TailOColors.coral,
                    onPressed: hasGps ? onGetDirections : null,
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

        // ✅ Share button sits below the map card
        if (hasGps) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onShareLocation,
              icon: const Icon(
                LucideIcons.share2,
                size: 16,
                color: TailOColors.coral,
              ),
              label: const Text(
                "Share ${''} Location",
                style: TextStyle(
                  color: TailOColors.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: TailOColors.coral, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildControlButton(
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
