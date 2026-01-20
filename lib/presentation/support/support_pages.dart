import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/services/support_service.dart';
import '../../data/models/support_models.dart';

// ==========================================
// 1. CONTACT SUPPORT (Chat)
// ==========================================
class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final TextEditingController _controller = TextEditingController();
  final SupportService _service = SupportService();
  final List<SupportMessage> _messages = [
    SupportMessage(
      id: 'init',
      text: "Hello! How can we help you today?",
      isMe: false,
      timestamp: DateTime.now(),
    ),
  ];
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Add User Message immediately
    setState(() {
      _messages.add(
        SupportMessage(
          id: DateTime.now().toString(),
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true; // Show loading state
    });
    _controller.clear();

    // 2. Get Response from Service
    final response = await _service.sendMessage(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(response);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("TailO Support"),
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 12),
                      child: Text(
                        "Agent is typing...",
                        style: TextStyle(
                          fontSize: 12,
                          color: TailOColors.muted,
                        ),
                      ),
                    ),
                  );
                }
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: const InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: TailOColors.muted),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(LucideIcons.send, color: TailOColors.coral),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SupportMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isMe ? TailOColors.coral : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: message.isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: message.isMe ? null : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isMe
                ? Colors.white
                : theme.textTheme.bodyLarge?.color,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. REPORT BUG PAGE
// ==========================================
class ReportBugPage extends StatefulWidget {
  const ReportBugPage({super.key});

  @override
  State<ReportBugPage> createState() => _ReportBugPageState();
}

class _ReportBugPageState extends State<ReportBugPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  void _submit() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isSubmitting = true);

    await SupportService().submitBugReport(_controller.text);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Report Sent! Thank you."),
          backgroundColor: TailOColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Report a Bug"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Describe the issue",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TailOColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 6,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: const InputDecoration(
                  hintText: "What happened? Steps to reproduce...",
                  hintStyle: TextStyle(color: TailOColors.muted),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TailOColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Report",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. DEVICE LOGS PAGE (Async Loader)
// ==========================================
class DeviceLogPage extends StatelessWidget {
  const DeviceLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Device Logs"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Fetch data properly using FutureBuilder
      body: FutureBuilder<List<DeviceLog>>(
        future: SupportService().fetchDeviceLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: TailOColors.coral),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No logs found.",
                style: TextStyle(color: TailOColors.muted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            separatorBuilder: (_, __) => Divider(color: theme.dividerColor),
            itemBuilder: (context, index) {
              final log = snapshot.data![index];
              return _LogItem(log: log);
            },
          );
        },
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final DeviceLog log;
  const _LogItem({required this.log});

  Color _getColor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.success:
        return TailOColors.success;
      case LogLevel.warning:
        return TailOColors.warning;
      case LogLevel.critical:
        return TailOColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(log.level);
    final timeStr =
        "${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            timeStr,
            style: const TextStyle(
              color: TailOColors.muted,
              fontSize: 13,
              fontFamily: 'Monospace',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              log.event,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              log.level.name.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
