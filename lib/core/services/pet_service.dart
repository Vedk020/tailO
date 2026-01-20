import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/pet_model.dart';
import 'storage_service.dart';

class PetService {
  final StorageService _storage;

  // State
  List<Pet> _pets = [];
  final ValueNotifier<String?> selectedPetIdNotifier = ValueNotifier(null);

  PetService(this._storage);

  // Getters
  List<Pet> get pets => List.unmodifiable(_pets);

  Pet get activePet {
    if (_pets.isEmpty) return _createGhostPet();
    return _pets.firstWhere(
      (p) => p.id == selectedPetIdNotifier.value,
      orElse: () => _pets.isNotEmpty ? _pets.first : _createGhostPet(),
    );
  }

  Future<void> init() async {
    try {
      final String? rawData = _storage.getString(StorageService.keyPets);
      if (rawData != null && rawData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawData);
        _pets = decoded.map((json) => Pet.fromJson(json)).toList();
      }

      if (_pets.isNotEmpty && selectedPetIdNotifier.value == null) {
        selectedPetIdNotifier.value = _pets.first.id;
      }
    } catch (e) {
      debugPrint("❌ Error loading pets: $e");
      _pets = [];
    }
  }

  // --- ACTIONS ---

  void switchPet(String id) {
    selectedPetIdNotifier.value = id;
  }

  Future<void> addPet(Pet pet) async {
    // Prevent duplicates based on ID
    if (_pets.any((p) => p.id == pet.id)) return;

    _pets.add(pet);
    selectedPetIdNotifier.value = pet.id;
    await _saveToStorage();
  }

  Future<void> removePet(String id) async {
    _pets.removeWhere((p) => p.id == id);
    if (selectedPetIdNotifier.value == id) {
      selectedPetIdNotifier.value = _pets.isNotEmpty ? _pets.first.id : null;
    }
    await _saveToStorage();
  }

  // ✅ METHOD 1: Connection Status
  Future<void> setPetConnection(String petId, bool status) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      _pets[index] = _pets[index].copyWith(isConnected: status);
      await _saveToStorage();
      selectedPetIdNotifier.notifyListeners();
    }
  }

  // ✅ METHOD 2: Add Medical Record
  Future<void> addMedicalRecord(String petId, MedicalRecord record) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final currentRecords = List<MedicalRecord>.from(
        _pets[index].medicalRecords,
      );
      currentRecords.insert(0, record);

      double newWeight = _pets[index].weight;
      if (record.weightSnapshot != null) newWeight = record.weightSnapshot!;

      _pets[index] = _pets[index].copyWith(
        weight: newWeight,
        medicalRecords: currentRecords,
      );

      await _saveToStorage();
      selectedPetIdNotifier.notifyListeners();
    }
  }

  // ✅ METHOD 3: Remove Medical Record
  Future<void> removeMedicalRecord(String petId, String recordId) async {
    final index = _pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      final currentRecords = List<MedicalRecord>.from(
        _pets[index].medicalRecords,
      );
      currentRecords.removeWhere((r) => r.id == recordId);

      _pets[index] = _pets[index].copyWith(medicalRecords: currentRecords);

      await _saveToStorage();
      selectedPetIdNotifier.notifyListeners();
    }
  }

  // ✅ METHOD 4: Inject Demo Data
  Future<void> injectDemoData(List<Pet> demoPets) async {
    if (_pets.isEmpty) {
      _pets.addAll(demoPets);
      if (_pets.isNotEmpty) selectedPetIdNotifier.value = _pets.first.id;
      await _saveToStorage();
    }
  }

  // --- HELPERS ---

  Future<void> _saveToStorage() async {
    await _storage.setString(
      StorageService.keyPets,
      jsonEncode(_pets.map((p) => p.toJson()).toList()),
    );
  }

  Pet _createGhostPet() {
    return Pet(
      id: '0',
      name: 'Unknown',
      type: 'dog',
      breed: '',
      gender: '',
      weight: 0.0,
      dob: DateTime.now(),
      image: 'assets/images/appLogo.png',
    );
  }
}
