import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// --- ENUMS (Type Safety) ---
enum ReminderCategory { walk, food, medicine, vet, grooming, custom }

enum ReminderFrequency { once, daily }

// --- MODEL ---
class Reminder {
  final String id;
  final String title;
  final TimeOfDay time;
  final ReminderFrequency frequency;
  final ReminderCategory category;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.frequency,
    required this.category,
    this.isCompleted = false,
  });

  // --- LOGIC: Centralized Icon Mapping ---
  IconData get icon {
    switch (category) {
      case ReminderCategory.walk:
        return LucideIcons.footprints;
      case ReminderCategory.food:
        return LucideIcons.utensils;
      case ReminderCategory.medicine:
        return LucideIcons.pill;
      case ReminderCategory.vet:
        return LucideIcons.stethoscope;
      case ReminderCategory.grooming:
        return LucideIcons.scissors;
      case ReminderCategory.custom:
        return LucideIcons.clock;
    }
  }

  // --- LOGIC: String Formatting ---
  String get frequencyLabel {
    switch (frequency) {
      case ReminderFrequency.once:
        return "Once";
      case ReminderFrequency.daily:
        return "Daily";
    }
  }

  String get categoryLabel {
    return category.name[0].toUpperCase() + category.name.substring(1);
  }

  // --- SERIALIZATION (For Storage) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'frequency': frequency.index, // Save as int
      'category': category.index, // Save as int
      'isCompleted': isCompleted,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      title: json['title'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      frequency: ReminderFrequency.values[json['frequency']],
      category: ReminderCategory.values[json['category']],
      isCompleted: json['isCompleted'],
    );
  }
}
