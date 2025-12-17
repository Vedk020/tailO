class MedicalRecord {
  final String id;
  final String type;
  final String title;
  final DateTime date;
  final String? weight;
  final String? notes;
  final String? attachmentPath;

  MedicalRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.weight,
    this.notes,
    this.attachmentPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'date': date.toIso8601String(),
    'weight': weight,
    'notes': notes,
    'attachmentPath': attachmentPath,
  };

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      weight: json['weight'],
      notes: json['notes'],
      attachmentPath: json['attachmentPath'],
    );
  }
}

class Pet {
  final String id;
  final String name;
  final String type;
  final String breed;
  final String gender;
  final String weight;
  final DateTime dob;
  final String image;
  bool isConnected;

  // Stats
  final double battery;
  final String heartRate;
  final String steps;
  final String calories; // NEW FIELD
  final String spo2;

  final List<MedicalRecord> medicalRecords;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.weight,
    required this.dob,
    required this.image,
    this.isConnected = true,
    this.battery = 0.85,
    this.heartRate = "72",
    this.steps = "5,400",
    this.calories = "350", // Default
    this.spo2 = "98",
    List<MedicalRecord>? medicalRecords,
  }) : medicalRecords = medicalRecords ?? [];

  String get age {
    final now = DateTime.now();
    final difference = now.difference(dob);
    final days = difference.inDays;
    if (days < 30) return "$days days";
    if (days < 365) return "${(days / 30).floor()} months";
    return "${(days / 365).floor()} years";
  }

  Map<String, dynamic> toJson() => {
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
    'calories': calories, // Save
    'spo2': spo2,
    'medicalRecords': medicalRecords.map((r) => r.toJson()).toList(),
  };

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      breed: json['breed'],
      gender: json['gender'],
      weight: json['weight'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : DateTime.now(),
      image: json['image'],
      isConnected: json['isConnected'] ?? false,
      battery: (json['battery'] as num?)?.toDouble() ?? 0.8,
      heartRate: json['heartRate'] ?? "0",
      steps: json['steps'] ?? "0",
      calories: json['calories'] ?? "0", // Load
      spo2: json['spo2'] ?? "0",
      medicalRecords: json['medicalRecords'] != null
          ? (json['medicalRecords'] as List)
                .map((i) => MedicalRecord.fromJson(i))
                .toList()
          : [],
    );
  }
}

class CommunityPost {
  final String id;
  final String author;
  final DateTime timestamp;
  final String content;
  final String? postImage;
  final int likes;
  final int comments;
  final bool isLiked; // NEW FIELD

  CommunityPost({
    required this.id,
    required this.author,
    required this.timestamp,
    required this.content,
    this.postImage,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false, // Default to false
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
}
