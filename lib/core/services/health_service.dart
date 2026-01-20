import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/pet_model.dart'; // Import Models

class HealthService {
  // 1. Centralized Icon Mapping
  static IconData getIconForType(String type) {
    switch (type) {
      case 'Vet':
        return LucideIcons.stethoscope;
      case 'Vaccine':
        return LucideIcons.syringe;
      case 'Meds':
        return LucideIcons.pill;
      case 'Weight':
        return LucideIcons.scale;
      case 'Illness':
        return LucideIcons.thermometer;
      default:
        return LucideIcons.fileText;
    }
  }

  // 2. Vitals Analysis Logic (Thresholds)
  static String analyzeHeartRate(int bpm) {
    if (bpm > 120) return "Abnormal High Heart Rate Detected!";
    if (bpm < 40 && bpm > 0) return "Abnormal Low Heart Rate Detected!";
    return "Routine auto-log.";
  }

  static String analyzeSpO2(int spo2) {
    if (spo2 < 95 && spo2 > 0) return "Low Oxygen Level Detected!";
    return "Routine auto-log.";
  }

  // 3. Create Record Helper
  static MedicalRecord createVitalLog({
    required String type,
    required String title,
    required String value,
    required String unit,
    double? currentWeight,
  }) {
    String note = "Routine auto-log.";

    // Parse value safely
    final int? numericValue = int.tryParse(value);

    if (numericValue != null) {
      if (type == "Heart Rate") {
        note = analyzeHeartRate(numericValue);
      } else if (type == "SpO2") {
        note = analyzeSpO2(numericValue);
      }
    }

    return MedicalRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: "Vet", // Categorize vitals under Vet/Checkup
      title: "$type Log",
      date: DateTime.now(),
      weightSnapshot: currentWeight,
      notes: "$title: $value $unit\n$note",
    );
  }
}
