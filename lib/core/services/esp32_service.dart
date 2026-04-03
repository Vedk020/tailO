import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Esp32Service {
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _charSub;

  // ✅ Updated to 6 params
  Function(int hr, int spo2, int steps, double battery, double lat, double lng)?
  onDataReceived;
  Function(bool isConnected)? onConnectionChanged;

  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String charUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  Future<void> connectHardware() async {
    await FlutterBluePlus.stopScan();

    _scanSub = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        print("Found ${results.length} devices...");
        if (r.device.platformName == "TailO_Collar" ||
            r.device.advName == "TailO_Collar") {
          await FlutterBluePlus.stopScan();
          await _connectToDevice(r.device);
          break;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;

      onConnectionChanged?.call(true);

      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == serviceUuid) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() == charUuid) {
              await characteristic.setNotifyValue(true);
              _charSub = characteristic.lastValueStream.listen(_parseData);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("BLE Connection failed: $e");
      disconnectHardware();
    }
  }

  // ✅ Updated to parse 6 values: HR, SPO2, STEPS, BATTERY, LAT, LNG
  void _parseData(List<int> value) {
    if (value.isEmpty) return;
    try {
      String dataStr = utf8.decode(value);
      List<String> parts = dataStr.trim().split(',');

      if (parts.length >= 6) {
        int hr = int.tryParse(parts[0]) ?? 0;
        int spo2 = int.tryParse(parts[1]) ?? 0;
        int steps = int.tryParse(parts[2]) ?? 0;
        double battery = double.tryParse(parts[3]) ?? 0.0;
        double lat = double.tryParse(parts[4]) ?? 0.0;
        double lng = double.tryParse(parts[5]) ?? 0.0;

        onDataReceived?.call(hr, spo2, steps, battery, lat, lng);
      }
    } catch (e) {
      debugPrint("Error parsing ESP32 data: $e");
    }
  }

  Future<void> disconnectHardware() async {
    await _charSub?.cancel();
    await _scanSub?.cancel();
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    onConnectionChanged?.call(false);
  }

  // --- Alpha Testing Hooks (called by DataService) ---
  void startAlphaTesting() => connectHardware();
  void stopAlphaTesting() => disconnectHardware();
}
