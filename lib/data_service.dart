import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For Icons
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pet_model.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Pet> _pets = [];
  bool _isLoggedIn = false;
  String _ownerName = "Agent Handler";
  String _ownerEmail = "handler@tailo.com";
  String _ownerPassword = "TAILO-GUEST-ACCESS-KEY";

  // --- GLOBAL STATE ---
  final ValueNotifier<String?> selectedPetIdNotifier = ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>> remindersNotifier =
      ValueNotifier([]);

  // --- COMMUNITY STATE ---
  final ValueNotifier<List<CommunityPost>> postsNotifier = ValueNotifier([]);

  // --- GETTERS ---
  List<Pet> get pets => _pets;
  bool get isLoggedIn => _isLoggedIn;
  String get ownerName => _ownerName;
  String get ownerEmail => _ownerEmail;
  String get ownerPassword => _ownerPassword;

  Pet get activePet {
    if (_pets.isEmpty) {
      return Pet(
        id: '0',
        name: 'Unknown',
        type: 'dog',
        breed: '',
        gender: '',
        weight: '',
        dob: DateTime.now(),
        image: 'assets/images/appLogo.png',
      );
    }
    return _pets.firstWhere(
      (p) => p.id == selectedPetIdNotifier.value,
      orElse: () => _pets.first,
    );
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

    final userInfo = prefs.getStringList(_userKey);
    if (userInfo != null && userInfo.length >= 3) {
      _ownerName = userInfo[0];
      _ownerEmail = userInfo[1];
      _ownerPassword = userInfo[2];
    } else if (userInfo != null && userInfo.length >= 2) {
      _ownerName = userInfo[0];
      _ownerEmail = userInfo[1];
    }

    final String? petsData = prefs.getString(_storageKeyPets);
    if (petsData != null) {
      _pets = (jsonDecode(petsData) as List)
          .map((json) => Pet.fromJson(json))
          .toList();
    }

    if (_pets.isNotEmpty) selectedPetIdNotifier.value = _pets.first.id;

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

  // --- COMMUNITY ACTIONS ---

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

  // NEW: Toggle Like Status
  void togglePostLike(String postId) {
    final List<CommunityPost> currentPosts = List.from(postsNotifier.value);
    final index = currentPosts.indexWhere((p) => p.id == postId);

    if (index != -1) {
      final post = currentPosts[index];
      // Create new copy with updated stats
      currentPosts[index] = CommunityPost(
        id: post.id,
        author: post.author,
        timestamp: post.timestamp,
        content: post.content,
        postImage: post.postImage,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        comments: post.comments,
        isLiked: !post.isLiked, // Flip state
      );
      postsNotifier.value = currentPosts; // Trigger UI update
    }
  }

  // NEW: Add Comment (Increments count)
  void addPostComment(String postId) {
    final List<CommunityPost> currentPosts = List.from(postsNotifier.value);
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
        comments: post.comments + 1, // Increment
        isLiked: post.isLiked,
      );
      postsNotifier.value = currentPosts;
    }
  }

  // --- USER ACTIONS ---
  Future<void> setUserInfo({
    required String email,
    String? name,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _ownerEmail = email;
    if (password != null) _ownerPassword = password;
    if (name != null && name.isNotEmpty) {
      _ownerName = name;
    } else {
      String derived = email.split('@')[0];
      _ownerName = derived[0].toUpperCase() + derived.substring(1);
    }
    await prefs.setStringList(_userKey, [
      _ownerName,
      _ownerEmail,
      _ownerPassword,
    ]);
  }

  Future<void> setLoginState(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = status;
    await prefs.setBool(_loginKey, status);
  }

  Future<void> logout() async => await setLoginState(false);

  // --- MEDICAL RECORD ACTIONS ---
  Future<void> addMedicalRecord(String petId, MedicalRecord record) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      _pets[index].medicalRecords.insert(0, record);
      if (record.weight != null && record.weight!.isNotEmpty) {
        final old = _pets[index];
        _pets[index] = Pet(
          id: old.id,
          name: old.name,
          type: old.type,
          breed: old.breed,
          gender: old.gender,
          weight: record.weight!,
          dob: old.dob,
          image: old.image,
          isConnected: old.isConnected,
          battery: old.battery,
          heartRate: old.heartRate,
          steps: old.steps,
          spo2: old.spo2,
          calories: old.calories,
          medicalRecords: old.medicalRecords,
        );
      }
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

  // --- REMINDER ACTIONS ---
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

  // --- PET ACTIONS ---
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

  // --- NEW: TOGGLE CONNECTION ---
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

  // --- DEMO DATA ---
  Future<void> loadDemoData() async {
    // Add Demo Posts with Images (Using Lorem Picsum for demo)
    if (postsNotifier.value.isEmpty) {
      postsNotifier.value = [
        CommunityPost(
          id: '1',
          author: "Ved k",
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          content: "Look at him go! 🚀",
          postImage: "https://placedog.net/640/480?random", // Mock Image
          likes: 45,
          comments: 12,
        ),
        CommunityPost(
          id: '2',
          author: "Mr. Daddy",
          timestamp: DateTime.now().subtract(Duration(hours: 5)),
          content: "Lazy Sunday... 😴",
          postImage: "https://placedog.net/600/400?id=20",
          likes: 128,
          comments: 45,
        ),
        CommunityPost(
          id: '3',
          author: "Vedu Bhai",
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          content: "Ready for the adventure! 🏞️",
          // No image for this one to test layout
          likes: 67,
          comments: 8,
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
      weight: "30 kg",
      dob: DateTime.now().subtract(const Duration(days: 365 * 3)),
      image: "assets/images/appLogo.png",
      isConnected: true,
      battery: 0.69,
      heartRate: "78",
      steps: "6,240",
      calories: "410",
      spo2: "98",
      medicalRecords: [
        MedicalRecord(
          id: "1",
          type: "Vet",
          title: "Annual Checkup",
          date: DateTime.now().subtract(const Duration(days: 120)),
          weight: "29.5 kg",
          notes: "Healthy, slightly active.",
        ),
        MedicalRecord(
          id: "2",
          type: "Vaccine",
          title: "Rabies Shot",
          date: DateTime.now().subtract(const Duration(days: 365)),
          weight: "28 kg",
          notes: "Next due in 1 year.",
        ),
      ],
    );
    final luna = Pet(
      id: "#15500",
      name: "Luna",
      type: "dog",
      breed: "Siberian Husky",
      gender: "Female",
      weight: "25 kg",
      dob: DateTime.now().subtract(const Duration(days: 365 * 2)),
      image: "assets/images/appLogo.png",
      isConnected: false,
      battery: 0.42,
      heartRate: "0",
      steps: "0",
      calories: "0",
      spo2: "0",
      medicalRecords: [
        MedicalRecord(
          id: "3",
          type: "Illness",
          title: "Stomach Upset",
          date: DateTime.now().subtract(const Duration(days: 10)),
          weight: "24.8 kg",
          notes: "Prescribed probiotics.",
        ),
      ],
    );

    _pets.addAll([rex, luna]);
    selectedPetIdNotifier.value = _pets.first.id;
    await _savePets();
  }

  // --- PERSISTENCE HELPERS ---
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
}
