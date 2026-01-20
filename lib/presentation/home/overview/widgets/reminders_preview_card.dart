import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/data_service.dart';
import '../../../../presentation/reminders/reminders_page.dart';
import '../../../../core/theme/colors.dart';

class RemindersPreviewCard extends StatelessWidget {
  const RemindersPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RemindersPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor, width: 0.5),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: DataService().remindersNotifier,
          builder: (context, reminders, _) {
            final active = reminders
                .where((r) => !r['isCompleted'])
                .take(3)
                .toList();

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Upcoming Reminders",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: TailOColors.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (active.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "No upcoming reminders",
                      style: TextStyle(color: TailOColors.muted),
                    ),
                  )
                else
                  ...active.asMap().entries.map((entry) {
                    return Column(
                      children: [
                        if (entry.key > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Divider(
                              color: theme.dividerColor,
                              height: 1,
                              thickness: 0.5,
                            ),
                          ),
                        _buildReminderItem(
                          context,
                          entry.value['icon'],
                          entry.value['title'],
                          entry.value['time'],
                        ),
                      ],
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    IconData icon,
    String title,
    String time,
  ) {
    return Row(
      children: [
        Icon(icon, color: TailOColors.coral, size: 20),
        const SizedBox(width: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Spacer(),
        Text(
          "— $time",
          style: const TextStyle(
            color: TailOColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
