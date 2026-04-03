import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  late AnimationController _pulseController;

  final List<ScanResult> _foundDevices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectingToId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startScan();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _foundDevices.clear();
      _isScanning = true;
      _errorMessage = null;
    });

    // Check Bluetooth is on
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = "Bluetooth is off. Please turn it on.";
        });
      }
      return;
    }

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        for (final r in results) {
          // Only show named devices
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.device.advName;
          if (name.isEmpty) continue;

          // Deduplicate by remoteId
          final exists = _foundDevices.any(
            (d) => d.device.remoteId == r.device.remoteId,
          );
          if (!exists) _foundDevices.add(r);
        }
      });
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    if (mounted) setState(() => _isScanning = false);
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _connectingToId = device.remoteId.toString();
    });

    // Tell DataService to connect (it will handle BLE internally)
    DataService().connectHardware();

    // Give it a moment to establish
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Connected to ${device.platformName.isNotEmpty ? device.platformName : device.advName}!",
          ),
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
          // Handle bar
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

          // Title
          Text(
            _isConnecting
                ? "Pairing..."
                : _isScanning
                ? "Searching for Collar..."
                : _foundDevices.isEmpty
                ? "No Devices Found"
                : "${_foundDevices.length} Device(s) Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? "Ensure the TailO belt is turned on.",
            style: TextStyle(
              color: _errorMessage != null ? Colors.red : TailOColors.muted,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          // ── SCANNING ANIMATION ──
          if (_isScanning || _isConnecting)
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) => Container(
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
                      ),
                    ),
                    // Center BT icon
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
                  ],
                ),
              ),
            )
          // ── DEVICE LIST ──
          else
            Expanded(
              child: Column(
                children: [
                  // Device cards
                  Expanded(
                    child: _foundDevices.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.bluetoothOff,
                                  size: 48,
                                  color: TailOColors.muted,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No devices nearby",
                                  style: TextStyle(color: TailOColors.muted),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            itemCount: _foundDevices.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final result = _foundDevices[index];
                              final device = result.device;
                              final name = device.platformName.isNotEmpty
                                  ? device.platformName
                                  : device.advName;
                              final isTailO = name == "TailO_Collar";
                              final isThisConnecting =
                                  _connectingToId == device.remoteId.toString();

                              return GestureDetector(
                                onTap: () => _connectToDevice(device),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isTailO
                                          ? TailOColors.coral
                                          : theme.dividerColor,
                                      width: isTailO ? 2 : 0.5,
                                    ),
                                    boxShadow: isTailO
                                        ? [
                                            BoxShadow(
                                              color: TailOColors.coral
                                                  .withOpacity(0.2),
                                              blurRadius: 12,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isTailO
                                              ? TailOColors.coral.withOpacity(
                                                  0.1,
                                                )
                                              : theme.dividerColor.withOpacity(
                                                  0.3,
                                                ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isTailO
                                              ? LucideIcons.cpu
                                              : LucideIcons.bluetooth,
                                          color: isTailO
                                              ? TailOColors.coral
                                              : TailOColors.muted,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Name + MAC
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isTailO
                                                    ? TailOColors.coral
                                                    : theme
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              device.remoteId.toString(),
                                              style: const TextStyle(
                                                color: TailOColors.muted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // RSSI signal strength
                                      Column(
                                        children: [
                                          Icon(
                                            _rssiIcon(result.rssi),
                                            size: 16,
                                            color: _rssiColor(result.rssi),
                                          ),
                                          Text(
                                            "${result.rssi} dBm",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _rssiColor(result.rssi),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(width: 10),

                                      // Connect button
                                      isThisConnecting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: TailOColors.coral,
                                              ),
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isTailO
                                                    ? TailOColors.coral
                                                    : theme.dividerColor
                                                          .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Connect",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: isTailO
                                                      ? Colors.white
                                                      : TailOColors.muted,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Scan again button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _startScan,
                        icon: const Icon(
                          LucideIcons.refreshCw,
                          size: 16,
                          color: TailOColors.coral,
                        ),
                        label: const Text(
                          "Scan Again",
                          style: TextStyle(
                            color: TailOColors.coral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: TailOColors.coral),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Signal strength helpers
  IconData _rssiIcon(int rssi) {
    if (rssi >= -60) return LucideIcons.wifi;
    if (rssi >= -75) return LucideIcons.wifi;
    return LucideIcons.wifiOff;
  }

  Color _rssiColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -75) return Colors.orange;
    return Colors.red;
  }
}
