import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/data_service.dart';

class DeviceScannerSheet extends StatefulWidget {
  final String petId;
  const DeviceScannerSheet({super.key, required this.petId});

  @override
  State<DeviceScannerSheet> createState() => _DeviceScannerSheetState();
}

class _DeviceScannerSheetState extends State<DeviceScannerSheet>
    with SingleTickerProviderStateMixin {
  bool _deviceFound = false;
  bool _isConnecting = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Radar Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Simulate finding the device after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _deviceFound = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _connectToDevice() async {
    setState(() => _isConnecting = true);

    // Call the actual hardware connection logic!
    DataService().connectHardware();

    // Wait for the service to establish connection (simulate small delay for UI)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Close the scanner
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            _isConnecting
                ? "Pairing..."
                : (_deviceFound ? "Device Found" : "Searching for Collar..."),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ensure the TailO belt is turned on.",
            style: const TextStyle(color: TailOColors.muted),
          ),

          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // RIPPLE ANIMATION
                  if (!_isConnecting)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 200 + (_pulseController.value * 100),
                          height: 200 + (_pulseController.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: TailOColors.coral.withOpacity(
                                1 - _pulseController.value,
                              ),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),

                  // CENTER ICON
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: TailOColors.coral.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.bluetooth,
                      color: TailOColors.coral,
                      size: 40,
                    ),
                  ),

                  // THE FOUND DEVICE (Appears after 2.5s)
                  if (_deviceFound && !_isConnecting)
                    Positioned(
                      top: 40,
                      right: 40,
                      child: GestureDetector(
                        onTap: _connectToDevice,
                        child: _buildDevicePill(),
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

  Widget _buildDevicePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: TailOColors.coral, width: 2),
        boxShadow: [
          BoxShadow(color: TailOColors.coral.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(LucideIcons.cpu, size: 16, color: TailOColors.coral),
          SizedBox(width: 8),
          Text("TailO_Collar", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
