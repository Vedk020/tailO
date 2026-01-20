enum LogLevel { info, success, warning, critical }

class DeviceLog {
  final String id;
  final DateTime timestamp;
  final String event;
  final LogLevel level;

  const DeviceLog({
    required this.id,
    required this.timestamp,
    required this.event,
    required this.level,
  });
}

class SupportMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const SupportMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}
