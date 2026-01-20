import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';
import '../../data/models/reminder_model.dart'; // Import the new model

class AddReminderSheet extends StatefulWidget {
  const AddReminderSheet({super.key});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  // Form State
  final TextEditingController _titleController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // ✅ Use Enums instead of Strings
  ReminderCategory _selectedCategory = ReminderCategory.custom;
  ReminderFrequency _selectedFrequency = ReminderFrequency.once;

  @override
  void initState() {
    super.initState();
    // Default Selection
    _updateCategory(ReminderCategory.walk);
  }

  void _updateCategory(ReminderCategory category) {
    setState(() {
      _selectedCategory = category;
      // Auto-fill title for convenience
      if (category != ReminderCategory.custom) {
        // Capitalize first letter
        _titleController.text =
            category.name[0].toUpperCase() + category.name.substring(1);
      } else {
        _titleController.clear();
      }
    });
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).cardColor,
              dialHandColor: TailOColors.coral,
              dialBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hourMinuteTextColor: TailOColors.coral,
              entryModeIconColor: TailOColors.coral,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: TailOColors.coral),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _save() {
    // 1. Validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a title"),
          backgroundColor: TailOColors.error,
        ),
      );
      return;
    }

    // 2. Create Model
    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      time: _selectedTime,
      frequency: _selectedFrequency,
      category: _selectedCategory,
    );

    // 3. Return Model
    Navigator.pop(context, newReminder);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: TailOColors.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            "New Reminder",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),

          // 1. CATEGORY SELECTOR (Horizontal Scroll)
          Text(
            "Type",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TailOColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ReminderCategory.values.map((cat) {
                // Using a temp reminder just to get the icon from the model logic
                final tempIcon = Reminder(
                  id: '',
                  title: '',
                  time: TimeOfDay.now(),
                  frequency: ReminderFrequency.once,
                  category: cat,
                ).icon;

                final isSelected = _selectedCategory == cat;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      cat.name[0].toUpperCase() + cat.name.substring(1),
                    ),
                    avatar: Icon(
                      tempIcon,
                      size: 16,
                      color: isSelected ? Colors.white : TailOColors.muted,
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) _updateCategory(cat);
                    },
                    backgroundColor: theme.cardColor,
                    selectedColor: TailOColors.coral,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.bodyLarge?.color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? TailOColors.coral
                            : theme.dividerColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // 2. TITLE INPUT
          TextField(
            controller: _titleController,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              labelText: "Title",
              labelStyle: const TextStyle(color: TailOColors.muted),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                LucideIcons.pencil,
                color: TailOColors.muted,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. TIME PICKER
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Time",
                          style: TextStyle(
                            fontSize: 12,
                            color: TailOColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _selectedTime.format(context),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              LucideIcons.clock,
                              color: TailOColors.coral,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 4. FREQUENCY TOGGLE
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  height: 90,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFreqOption("Once", ReminderFrequency.once),
                      _buildFreqOption("Daily", ReminderFrequency.daily),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // SAVE BUTTON
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: TailOColors.coral,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                "Set Reminder",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildFreqOption(String label, ReminderFrequency val) {
    final isSelected = _selectedFrequency == val;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFrequency = val),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSelected
                ? TailOColors.coral.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? TailOColors.coral
                  : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}
