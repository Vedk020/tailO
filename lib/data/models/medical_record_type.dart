import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum MedicalRecordType { vet, vaccine, meds, illness, weight, other }

extension MedicalRecordTypeExtension on MedicalRecordType {
  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }

  IconData get icon {
    switch (this) {
      case MedicalRecordType.vet:
        return LucideIcons.stethoscope;
      case MedicalRecordType.vaccine:
        return LucideIcons.syringe;
      case MedicalRecordType.meds:
        return LucideIcons.pill;
      case MedicalRecordType.illness:
        return LucideIcons.thermometer;
      case MedicalRecordType.weight:
        return LucideIcons.scale;
      case MedicalRecordType.other:
        return LucideIcons.fileText;
    }
  }
}
