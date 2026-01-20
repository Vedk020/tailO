import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/theme/colors.dart';

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
