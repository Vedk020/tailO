import 'package:flutter/foundation.dart';

// ------------------------------------------------------
// 🐾 PET MODEL (Strictly Typed)
// ------------------------------------------------------
class Pet {
  final String id;
  final String name;
  final String type; // 'dog', 'cat'
  final String breed;
  final String gender;
  final double weight; // Changed to double (kg)
  final DateTime dob;
  final String image;

  // Connection State
  final bool isConnected;
  final double battery; // 0.0 to 1.0

  // Health Stats (Strict Types)
  final int heartRate; // bpm
  final int steps; // count
  final int calories; // kcal
  final int spo2; // percentage

  final List<MedicalRecord> medicalRecords;

  const Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.weight,
    required this.dob,
    required this.image,
    this.isConnected = false,
    this.battery = 1.0,
    this.heartRate = 0,
    this.steps = 0,
    this.calories = 0,
    this.spo2 = 0,
    this.medicalRecords = const [],
  });

  // --- FACTORY (JSON -> Object) ---
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      breed: json['breed'] as String,
      gender: json['gender'] as String,
      weight: (json['weight'] as num).toDouble(),
      dob: DateTime.parse(json['dob']),
      image: json['image'] as String,
      isConnected: json['isConnected'] as bool? ?? false,
      battery: (json['battery'] as num?)?.toDouble() ?? 1.0,
      heartRate: json['heartRate'] as int? ?? 0,
      steps: json['steps'] as int? ?? 0,
      calories: json['calories'] as int? ?? 0,
      spo2: json['spo2'] as int? ?? 0,
      medicalRecords:
          (json['medicalRecords'] as List<dynamic>?)
              ?.map((e) => MedicalRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // --- SERIALIZATION (Object -> JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'gender': gender,
      'weight': weight,
      'dob': dob.toIso8601String(),
      'image': image,
      'isConnected': isConnected,
      'battery': battery,
      'heartRate': heartRate,
      'steps': steps,
      'calories': calories,
      'spo2': spo2,
      'medicalRecords': medicalRecords.map((e) => e.toJson()).toList(),
    };
  }

  // --- COPY WITH (Immutability Helper) ---
  Pet copyWith({
    String? name,
    String? type,
    String? breed,
    String? gender,
    double? weight,
    DateTime? dob,
    String? image,
    bool? isConnected,
    double? battery,
    int? heartRate,
    int? steps,
    int? calories,
    int? spo2,
    List<MedicalRecord>? medicalRecords,
  }) {
    return Pet(
      id: id, // ID never changes
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      dob: dob ?? this.dob,
      image: image ?? this.image,
      isConnected: isConnected ?? this.isConnected,
      battery: battery ?? this.battery,
      heartRate: heartRate ?? this.heartRate,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      spo2: spo2 ?? this.spo2,
      medicalRecords: medicalRecords ?? this.medicalRecords,
    );
  }
}

// ------------------------------------------------------
// 🏥 MEDICAL RECORD MODEL
// ------------------------------------------------------
class MedicalRecord {
  final String id;
  final String type; // Vet, Vaccine, Illness
  final String title;
  final DateTime date;
  final double? weightSnapshot; // Weight at time of record
  final String? notes;
  final String? attachmentPath;

  const MedicalRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.weightSnapshot,
    this.notes,
    this.attachmentPath,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date']),
      weightSnapshot: (json['weightSnapshot'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      attachmentPath: json['attachmentPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'date': date.toIso8601String(),
      'weightSnapshot': weightSnapshot,
      'notes': notes,
      'attachmentPath': attachmentPath,
    };
  }
}

// ------------------------------------------------------
