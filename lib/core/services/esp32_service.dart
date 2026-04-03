import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Needed to check if the phone is Android or iOS
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Esp32Service {
  final String targetDeviceName = "TailO_Collar";
  // ✅ Your ESP32 MAC Address
  final String targetMacAddress = "78:42:1C:6D:07:56";

  final String targetServiceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String targetCharUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _charSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);
  final ValueNotifier<Map<String, dynamic>?> liveVitals = ValueNotifier(null);

  Future<void> startAlphaTesting() async {
    // 1. Check if Bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      debugPrint("❌ Bluetooth not supported by this device");
      return;
    }

    // 2. ⚡ DIRECT CONNECTION (Android Only - Super Fast)
    // Android allows direct MAC address connections, skipping the slow scan!
    if (Platform.isAndroid) {
      debugPrint(
        "⚡ Android detected. Connecting instantly to MAC: $targetMacAddress...",
      );
      try {
        _connectedDevice = BluetoothDevice.fromId(targetMacAddress);
        await _connectToDevice(_connectedDevice!);
        return; // Success! Exit the function so we don't scan.
      } catch (e) {
        debugPrint("⚠️ Direct MAC connection failed, falling back to scan: $e");
      }
    }

    // 3. 🔍 SCAN FALLBACK (For iOS or if Android direct connect fails)
    // iOS hides MAC addresses, so we MUST scan by name.
    debugPrint("🔍 Scanning for $targetDeviceName...");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // Match by Name (iOS) OR by MAC (Android)
        if (r.device.platformName == targetDeviceName ||
            r.device.remoteId.str == targetMacAddress) {
          debugPrint("✅ Found TailO Collar! Connecting...");
          FlutterBluePlus.stopScan();
          _connectToDevice(r.device);
          break;
        }
      }
    });
  }

  void stopAlphaTesting() {
    _cleanup();
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;

    // Listen to connection state so the UI knows if it disconnects
    _connSub = device.connectionState.listen((BluetoothConnectionState state) {
      if (state == BluetoothConnectionState.disconnected) {
        isConnected.value = false;
        debugPrint("⚠️ TailO Collar Disconnected");
        _cleanup(
          keepDevice: true,
        ); // Keep device info to try reconnecting later
      }
    });

    try {
      // ✅ Included the free license requirement you ran into earlier!
      await device.connect(license: License.free);
      isConnected.value = true;
      debugPrint("✅ Connected! Discovering Services...");

      // Find the specific data pipe (Characteristic)
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == targetServiceUuid) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                targetCharUuid) {
              _subscribeToVitals(characteristic);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Connection failed: $e");
    }
  }

  Future<void> _subscribeToVitals(BluetoothCharacteristic char) async {
    debugPrint("🎧 Listening to Vitals stream...");

    // Tell ESP32 to start pushing notifications
    await char.setNotifyValue(true);

    // Read the incoming bytes and convert to JSON
    _charSub = char.onValueReceived.listen((value) {
      final String jsonString = utf8.decode(value);
      try {
        final data = jsonDecode(jsonString);
        liveVitals.value = data;
        // debugPrint("Live Data: $data"); // Uncomment to see data in console
      } catch (e) {
        debugPrint("Error parsing BLE JSON: $e");
      }
    });
  }

  void _cleanup({bool keepDevice = false}) {
    _scanSub?.cancel();
    _charSub?.cancel();
    _connSub?.cancel();

    if (!keepDevice) {
      _connectedDevice?.disconnect();
      _connectedDevice = null;
      isConnected.value = false;
    }
  }
}
