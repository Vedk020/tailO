import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/pet_model.dart';
import '../../data/models/community_post.dart';

import 'storage_service.dart';
import 'auth_service.dart';
import 'pet_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // --- SUB-SERVICES ---
  final StorageService _storage = StorageService();
  late final AuthService _auth;
  late final PetService _petService;

  // --- NOTIFIERS ---
  ValueNotifier<String?> get selectedPetIdNotifier =>
      _petService.selectedPetIdNotifier;
  ValueNotifier<bool> get isLoggedInNotifier => _auth.isLoggedInNotifier;

  final ValueNotifier<List<Map<String, dynamic>>> remindersNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<CommunityPost>> postsNotifier = ValueNotifier([]);

  // --- INIT ---
  Future<void> init({bool enableDemo = kDebugMode}) async {
    await _storage.init();
    _auth = AuthService(_storage);
    await _auth.init();
    _petService = PetService(_storage);
    await _petService.init();

    _loadReminders();

    if (enableDemo && _petService.pets.isEmpty) {
      await _loadDemoData();
    }
  }

  // --- GETTERS ---
  bool get isLoggedIn => _auth.isLoggedIn;
  String get ownerName => _auth.userName;
  String get ownerEmail => _auth.userEmail;
  String get ownerImage => _auth.userImage;
  List<Pet> get pets => _petService.pets;
  Pet get activePet => _petService.activePet;

  // --- ACTIONS ---
  Future<void> setUserInfo({
    required String email,
    required String name,
    String? password,
    String? imagePath,
  }) async {
    await _auth.updateProfile(name: name, email: email, imagePath: imagePath);
  }

  Future<void> setLoginState(bool status) async {
    if (status)
      await _auth.login("dummy", "dummy");
    else
      await _auth.logout();
  }

  Future<void> logout() async {
    await _auth.logout();
    remindersNotifier.value = [];
  }

  void switchPet(String id) => _petService.switchPet(id);
  Future<void> addPet(Pet pet) => _petService.addPet(pet);
  Future<void> removePet(String id) => _petService.removePet(id);

  // ✅ Now these methods exist in PetService
  Future<void> setPetConnection(String id, bool status) =>
      _petService.setPetConnection(id, status);
  Future<void> addMedicalRecord(String petId, MedicalRecord record) =>
      _petService.addMedicalRecord(petId, record);
  Future<void> removeMedicalRecord(String petId, String recordId) =>
      _petService.removeMedicalRecord(petId, recordId);

  // --- REMINDERS ---
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

  // ✅ Fixed duplicate _saveReminders logic
  Future<void> _saveReminders() async {
    final data = remindersNotifier.value.map((r) {
      final int codePoint = (r['icon'] as IconData).codePoint;
      return {
        'title': r['title'],
        'time': r['time'],
        'freq': r['freq'],
        'isCompleted': r['isCompleted'],
        'iconCode': codePoint,
      };
    }).toList();
    await _storage.setString(StorageService.keyReminders, jsonEncode(data));
  }

  // ✅ Fixed duplicate _loadReminders logic
  void _loadReminders() {
    try {
      final String? remindersData = _storage.getString(
        StorageService.keyReminders,
      );
      if (remindersData != null) {
        final List<dynamic> decoded = jsonDecode(remindersData);
        remindersNotifier.value = decoded.map((item) {
          final map = Map<String, dynamic>.from(item);
          map['icon'] = _getIconData(map['iconCode']);
          return map;
        }).toList();
      } else {
        _loadDefaultReminders();
      }
    } catch (e) {
      debugPrint("Error parsing reminders: $e");
      _loadDefaultReminders();
    }
  }

  void _loadDefaultReminders() {
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

  // --- COMMUNITY ---
  void addPost(String content, {String? image}) {
    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: ownerName,
      timestamp: DateTime.now(),
      content: content,
      postImage: image,
      likes: 0,
      comments: 0,
      isLiked: false,
    );
    final currentPosts = List<CommunityPost>.from(postsNotifier.value);
    postsNotifier.value = [newPost, ...currentPosts];
  }

  void togglePostLike(String postId) {
    final list = List<CommunityPost>.from(postsNotifier.value);
    final index = list.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final oldPost = list[index];
      list[index] = oldPost.copyWith(
        isLiked: !oldPost.isLiked,
        likes: oldPost.isLiked ? oldPost.likes - 1 : oldPost.likes + 1,
      );
      postsNotifier.value = list;
    }
  }

  void addPostComment(String postId) {
    final list = List<CommunityPost>.from(postsNotifier.value);
    final index = list.indexWhere((p) => p.id == postId);
    if (index != -1) {
      list[index] = list[index].copyWith(comments: list[index].comments + 1);
      postsNotifier.value = list;
    }
  }

  // --- HELPERS ---
  Future<void> _loadDemoData() async {
    final demoPet = Pet(
      id: "#12450",
      name: "Rex",
      type: "dog",
      breed: "Golden Retriever",
      gender: "Male",
      weight: 30.0,
      dob: DateTime.now().subtract(const Duration(days: 365 * 3)),
      image: "assets/images/appLogo.png",
      isConnected: true,
      battery: 0.85,
      heartRate: 72,
      steps: 5400,
      calories: 350,
      spo2: 98,
    );
    // ✅ Now this works because we added it to PetService
    await _petService.injectDemoData([demoPet]);

    postsNotifier.value = [
      CommunityPost(
        id: '1',
        author: 'TailO Team',
        timestamp: DateTime.now(),
        content: 'Welcome to the community!',
        likes: 10,
        isLiked: false,
      ),
    ];
  }

  IconData _getIconData(int? code) {
    if (code == null) return LucideIcons.clock;
    return IconData(code, fontFamily: 'Lucide', fontPackage: 'lucide_icons');
  }

  static ImageProvider getImageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('assets')) return AssetImage(path);
    return FileImage(File(path));
  }
}
