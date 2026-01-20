import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../core/services/data_service.dart';
import 'add_reminder_sheet.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Reminders",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: TailOColors.coral),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: DataService().remindersNotifier,
        builder: (context, reminders, _) {
          if (reminders.isEmpty) {
            return const _EmptyState();
          }

          // Segregate Data (Clean Logic)
          final today = reminders
              .where((r) => !r['isCompleted'] && r['freq'] == 'Daily')
              .toList();
          final upcoming = reminders
              .where((r) => !r['isCompleted'] && r['freq'] != 'Daily')
              .toList();
          final completed = reminders
              .where((r) => r['isCompleted'] == true)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (today.isNotEmpty) ...[
                  const _SectionHeader("Today"),
                  ...today.map(
                    (r) => _DismissibleReminder(
                      item: r,
                      originalIndex: reminders.indexOf(r),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (upcoming.isNotEmpty) ...[
                  const _SectionHeader("Upcoming"),
                  ...upcoming.map(
                    (r) => _DismissibleReminder(
                      item: r,
                      originalIndex: reminders.indexOf(r),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (completed.isNotEmpty) ...[
                  const _SectionHeader("Completed"),
                  ...completed.map(
                    (r) => _DismissibleReminder(
                      item: r,
                      originalIndex: reminders.indexOf(r),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddReminderSheet(),
    );
    if (result != null) {
      DataService().addReminder(result);
    }
  }
}

// ------------------------------------------------------
// 🧩 EXTRACTED WIDGETS (Performance & Readability)
// ------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TailOColors.muted,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(LucideIcons.bellOff, size: 48, color: TailOColors.muted),
          SizedBox(height: 16),
          Text("No reminders yet", style: TextStyle(color: TailOColors.muted)),
        ],
      ),
    );
  }
}

class _DismissibleReminder extends StatelessWidget {
  final Map<String, dynamic> item;
  final int originalIndex;

  const _DismissibleReminder({required this.item, required this.originalIndex});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("${item['title']}_$originalIndex"), // Stable Key
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: TailOColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: TailOColors.error),
      ),
      onDismissed: (direction) {
        DataService().deleteReminder(originalIndex);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reminder deleted"),
            duration: Duration(seconds: 1),
            backgroundColor: TailOColors.coral,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ReminderCard(item: item, index: originalIndex),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _ReminderCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isCompleted = item['isCompleted'];

    return GestureDetector(
      onTap: () => DataService().toggleReminder(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? theme.dividerColor.withValues(alpha: 0.5)
                : theme.dividerColor,
          ),
          boxShadow: [
            if (!isDark && !isCompleted)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? theme.dividerColor
                    : TailOColors.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item['icon'],
                color: isCompleted ? TailOColors.muted : TailOColors.coral,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? TailOColors.muted
                          : theme.textTheme.bodyLarge?.color,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item['time']} · ${item['freq']}",
                    style: TextStyle(
                      fontSize: 13,
                      color: TailOColors.muted.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? TailOColors.coral : TailOColors.muted,
                  width: 2,
                ),
                color: isCompleted ? TailOColors.coral : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
