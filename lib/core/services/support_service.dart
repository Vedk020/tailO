import 'dart:math';
import '../../data/models/support_models.dart';

class SupportService {
  // Simulate Network Delay
  Future<void> _simulateNetwork() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // --- DEVICE LOGS ---
  Future<List<DeviceLog>> fetchDeviceLogs() async {
    await _simulateNetwork();

    // Mock Data (but structured correctly)
    return [
      DeviceLog(
        id: '1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        event: "Heart Rate Sync",
        level: LogLevel.success,
      ),
      DeviceLog(
        id: '2',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        event: "GPS Signal Lost",
        level: LogLevel.warning,
      ),
      DeviceLog(
        id: '3',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        event: "Device Connected",
        level: LogLevel.info,
      ),
      DeviceLog(
        id: '4',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        event: "Battery Low (15%)",
        level: LogLevel.critical,
      ),
    ];
  }

  // --- BUG REPORTING ---
  Future<bool> submitBugReport(String description) async {
    await _simulateNetwork();
    // In real app: POST /api/bugs
    return true;
  }

  // --- CHAT BOT ---
  Future<SupportMessage> sendMessage(String text) async {
    // 1. In real app, send user message to server
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Simulate Bot Response delay
    await Future.delayed(const Duration(seconds: 1));

    return SupportMessage(
      id: DateTime.now().toString(),
      text:
          "Thanks for reaching out! A support agent will review your message: \"$text\"",
      isMe: false,
      timestamp: DateTime.now(),
    );
  }
}
