import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'add_reminder_sheet.dart';
import 'data_service.dart'; // Import DataService

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reminders",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: TailOColors.coral),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddReminderSheet(),
              );
              if (result != null) {
                // ADD TO DATA SERVICE (SAVES TO CACHE)
                DataService().addReminder(result);
              }
            },
          ),
        ],
      ),
      // LISTEN TO GLOBAL REMINDERS
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: DataService().remindersNotifier,
        builder: (context, reminders, _) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff, size: 48, color: TailOColors.muted),
                  const SizedBox(height: 16),
                  const Text(
                    "No reminders",
                    style: TextStyle(color: TailOColors.muted),
                  ),
                ],
              ),
            );
          }

          // Filter Lists
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
                  _sectionHeader("Today"),
                  ...today.map(
                    (r) =>
                        _buildDismissibleCard(context, r, reminders.indexOf(r)),
                  ),
                  const SizedBox(height: 24),
                ],
                if (upcoming.isNotEmpty) ...[
                  _sectionHeader("Upcoming"),
                  ...upcoming.map(
                    (r) =>
                        _buildDismissibleCard(context, r, reminders.indexOf(r)),
                  ),
                  const SizedBox(height: 24),
                ],
                if (completed.isNotEmpty) ...[
                  _sectionHeader("Completed"),
                  ...completed.map(
                    (r) =>
                        _buildDismissibleCard(context, r, reminders.indexOf(r)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
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

  Widget _buildDismissibleCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    return Dismissible(
      key: Key("${item['title']}_$index"), // Unique key
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.red),
      ),
      onDismissed: (direction) {
        // DELETE FROM DATA SERVICE
        DataService().deleteReminder(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reminder deleted"),
            duration: Duration(seconds: 2),
            backgroundColor: TailOColors.coral,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildReminderCard(context, item, index),
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isCompleted = item['isCompleted'];

    return GestureDetector(
      onTap: () {
        // TOGGLE IN DATA SERVICE
        DataService().toggleReminder(index);
      },
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
