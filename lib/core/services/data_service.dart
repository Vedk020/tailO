import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/pet_model.dart';
import '../../data/models/community_post.dart';
import 'esp32_service.dart'; // ✅ Brought back ESP32
import '../../bootstrap/dependency_injection.dart'; // To access sl

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Pet> _pets = [];
  bool _isLoggedIn = false;
  String _ownerName = "Agent Handler";
  String _ownerEmail = "handler@tailo.com";
  String _ownerPassword = "TAILO-GUEST-ACCESS-KEY";
  String _ownerImage = "assets/images/pfp.jpeg";

  // ✅ Brought back Hardware Service
  late final Esp32Service _esp32;

  // --- GLOBAL STATE ---
  final ValueNotifier<String?> selectedPetIdNotifier = ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>> remindersNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<CommunityPost>> postsNotifier = ValueNotifier([]);

  // ✅ Brought back Login Notifier (Fixes main.dart Error)
  final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);

  // --- GETTERS ---
  List<Pet> get pets => _pets;
  bool get isLoggedIn => _isLoggedIn;
  String get ownerName => _ownerName;
  String get ownerEmail => _ownerEmail;
  String get ownerPassword => _ownerPassword;
  String get ownerImage => _ownerImage;

  Pet get activePet {
    if (_pets.isEmpty) {
      return Pet(
        id: '0',
        name: 'Unknown',
        type: 'dog',
        breed: '',
        gender: '',
        weight: 0.0, // ✅ Fixed: double instead of String
        dob: DateTime.now(),
        image: 'assets/images/appLogo.png',
        battery: 1.0, // ✅ Added missing fields
        heartRate: 0,
        steps: 0,
        calories: 0,
        spo2: 0,
        isConnected: false,
      );
    }
    return _pets.firstWhere(
      (p) => p.id == selectedPetIdNotifier.value,
      orElse: () => _pets.first,
    );
  }

  // --- HELPER: GET IMAGE PROVIDER ---
  static ImageProvider getImageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('assets')) return AssetImage(path);
    return FileImage(File(path));
  }

  // --- STORAGE KEYS ---
  static const String _storageKeyPets = 'tailO_pets_data';
  static const String _storageKeyReminders = 'tailO_reminders_data';
  static const String _loginKey = 'tailO_is_logged_in';
  static const String _userKey = 'tailO_user_info';

  // --- INIT ---
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_loginKey) ?? false;
    isLoggedInNotifier.value = _isLoggedIn; // ✅ Sync notifier

    // Init Hardware
    _esp32 = sl<Esp32Service>();

    // Load User
    final userInfo = prefs.getStringList(_userKey);
    if (userInfo != null && userInfo.isNotEmpty) {
      _ownerName = userInfo[0];
      if (userInfo.length >= 2) _ownerEmail = userInfo[1];
      if (userInfo.length >= 3) _ownerPassword = userInfo[2];
      if (userInfo.length >= 4) _ownerImage = userInfo[3];
    }

    // Load Pets
    final String? petsData = prefs.getString(_storageKeyPets);
    if (petsData != null) {
      _pets = (jsonDecode(petsData) as List)
          .map((json) => Pet.fromJson(json))
          .toList();
    }

    if (_pets.isNotEmpty && selectedPetIdNotifier.value == null) {
      selectedPetIdNotifier.value = _pets.first.id;
    }

    // Load Reminders
    final String? remindersData = prefs.getString(_storageKeyReminders);
    if (remindersData != null) {
      final List<dynamic> decoded = jsonDecode(remindersData);
      remindersNotifier.value = decoded
          .map(
            (item) => {
              ...item as Map<String, dynamic>,
              'icon': _getIconData(item['iconCode']),
            },
          )
          .toList();
    } else {
      remindersNotifier.value = [
        {
          'title': 'Evening Walk',
          'time': '6:30 PM',
          'freq': 'Daily',
          'icon': LucideIcons.footprints,
          'isCompleted': false,
        },
        {
          'title': 'Dinner',
          'time': '8:00 PM',
          'freq': 'Daily',
          'icon': LucideIcons.utensils,
          'isCompleted': false,
        },
      ];
    }
  }

  // --- HARDWARE ACTIONS (Fixes UI Errors) ---
  void connectHardware() => _esp32.startAlphaTesting();
  void disconnectHardware() => _esp32.stopAlphaTesting();

  // --- USER ACTIONS ---
  Future<void> setUserInfo({
    required String email,
    String? name,
    String? password,
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _ownerEmail = email;
    if (password != null) _ownerPassword = password;
    if (imagePath != null) _ownerImage = imagePath;

    if (name != null && name.isNotEmpty) {
      _ownerName = name;
    } else {
      if (email.contains('@')) {
        String derived = email.split('@')[0];
        _ownerName = derived[0].toUpperCase() + derived.substring(1);
      } else {
        _ownerName = "User";
      }
    }

    await prefs.setStringList(_userKey, [
      _ownerName,
      _ownerEmail,
      _ownerPassword,
      _ownerImage,
    ]);
  }

  Future<void> setLoginState(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = status;
    isLoggedInNotifier.value = status; // ✅ Sync notifier
    await prefs.setBool(_loginKey, status);
  }

  // --- LOGOUT ACTION ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginKey);
    await prefs.remove(_userKey);
    await prefs.remove(_storageKeyPets);
    await prefs.remove(_storageKeyReminders);

    _isLoggedIn = false;
    isLoggedInNotifier.value = false;
    _ownerName = "Agent Handler";
    _ownerEmail = "handler@tailo.com";
    _ownerPassword = "";
    _ownerImage = "assets/images/pfp.jpeg";

    _pets.clear();
    selectedPetIdNotifier.value = null;
    remindersNotifier.value = [];
  }

  // --- COMMUNITY ACTIONS ---
  // ... (Your Community Post methods remain exactly the same here)
  void addPost(String content, {String? image}) {
    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: _ownerName,
      timestamp: DateTime.now(),
      content: content,
      postImage: image,
      likes: 0,
      comments: 0,
      isLiked: false,
    );
    postsNotifier.value = [newPost, ...postsNotifier.value];
  }

  void togglePostLike(String postId) {
    final currentPosts = List<CommunityPost>.from(postsNotifier.value);
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = currentPosts[index];
      currentPosts[index] = CommunityPost(
        id: post.id,
        author: post.author,
        timestamp: post.timestamp,
        content: post.content,
        postImage: post.postImage,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        comments: post.comments,
        isLiked: !post.isLiked,
      );
      postsNotifier.value = currentPosts;
    }
  }

  void addPostComment(String postId) {
    final currentPosts = List<CommunityPost>.from(postsNotifier.value);
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = currentPosts[index];
      currentPosts[index] = CommunityPost(
        id: post.id,
        author: post.author,
        timestamp: post.timestamp,
        content: post.content,
        postImage: post.postImage,
        likes: post.likes,
        comments: post.comments + 1,
        isLiked: post.isLiked,
      );
      postsNotifier.value = currentPosts;
    }
  }

  // --- PET/MEDICAL ACTIONS ---
  Future<void> addMedicalRecord(String petId, MedicalRecord record) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      _pets[index].medicalRecords.insert(0, record);
      // ✅ Removed the weight logic here that was causing the MedicalRecord errors
      await _savePets();
      selectedPetIdNotifier.notifyListeners();
    }
  }

  Future<void> removeMedicalRecord(String petId, String recordId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      _pets[index].medicalRecords.removeWhere((r) => r.id == recordId);
      await _savePets();
      selectedPetIdNotifier.notifyListeners();
    }
  }

  void switchPet(String id) => selectedPetIdNotifier.value = id;

  Future<void> addPet(Pet pet) async {
    _pets.add(pet);
    selectedPetIdNotifier.value = pet.id;
    await _savePets();
  }

  Future<void> removePet(String id) async {
    _pets.removeWhere((p) => p.id == id);
    if (selectedPetIdNotifier.value == id) {
      selectedPetIdNotifier.value = _pets.isNotEmpty ? _pets.first.id : null;
    }
    await _savePets();
  }

  Future<void> setPetConnection(String petId, bool status) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final old = _pets[index];
      _pets[index] = Pet(
        id: old.id,
        name: old.name,
        type: old.type,
        breed: old.breed,
        gender: old.gender,
        weight: old.weight,
        dob: old.dob,
        image: old.image,
        isConnected: status,
        battery: old.battery,
        heartRate: old.heartRate,
        steps: old.steps,
        calories: old.calories,
        spo2: old.spo2,
        medicalRecords: old.medicalRecords,
      );
      await _savePets();
      selectedPetIdNotifier.notifyListeners();
    }
  }

  // --- REMINDERS ACTIONS ---
  void addReminder(Map<String, dynamic> item) {
    remindersNotifier.value = List.from(remindersNotifier.value)
      ..insert(0, item);
    _saveReminders();
  }

  void toggleReminder(int index) {
    final list = List<Map<String, dynamic>>.from(remindersNotifier.value);
    list[index]['isCompleted'] = !list[index]['isCompleted'];
    remindersNotifier.value = list;
    _saveReminders();
  }

  void deleteReminder(int index) {
    final list = List<Map<String, dynamic>>.from(remindersNotifier.value);
    list.removeAt(index);
    remindersNotifier.value = list;
    _saveReminders();
  }

  // --- SAVERS & HELPERS ---
  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = remindersNotifier.value
        .map((r) => {...r, 'iconCode': (r['icon'] as IconData).codePoint})
        .toList();
    await prefs.setString(_storageKeyReminders, jsonEncode(data));
  }

  Future<void> _savePets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKeyPets,
      jsonEncode(_pets.map((p) => p.toJson()).toList()),
    );
  }

  IconData _getIconData(int? code) {
    if (code == null) return LucideIcons.clock;
    return IconData(code, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  }

  Future<void> loadDemoData() async {
    if (postsNotifier.value.isEmpty) {
      postsNotifier.value = [
        CommunityPost(
          id: '1',
          author: "Aryan",
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          content: "Look at him go! 🚀",
          postImage: "https://placedog.net/640/480?random",
          likes: 45,
          comments: 12,
        ),
        CommunityPost(
          id: '2',
          author: "Abhishek",
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          content: "Lazy Sunday... 😴",
          postImage: "https://placedog.net/600/400?id=20",
          likes: 128,
          comments: 45,
        ),
      ];
    }
    if (_pets.isNotEmpty) return;

    final rex = Pet(
      id: "#12450",
      name: "Rex",
      type: "dog",
      breed: "Golden Retriever",
      gender: "Male",
      weight: 30.0, // ✅ Fixed: Double
      dob: DateTime.now().subtract(const Duration(days: 365 * 3)),
      image: "assets/images/appLogo.png",
      isConnected: true,
      battery: 0.69,
      heartRate: 78, // ✅ Fixed: Int
      steps: 6240, // ✅ Fixed: Int
      calories: 410, // ✅ Fixed: Int
      spo2: 98, // ✅ Fixed: Int
      medicalRecords: [
        MedicalRecord(
          id: "1",
          type: "Vet",
          title: "Annual Checkup",
          date: DateTime.now().subtract(const Duration(days: 120)),
          notes: "Healthy, slightly active.",
        ),
      ],
    );

    _pets.addAll([rex]);
    selectedPetIdNotifier.value = _pets.first.id;
    await _savePets();
  }
}
