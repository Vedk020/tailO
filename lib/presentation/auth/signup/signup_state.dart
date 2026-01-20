import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/data_service.dart';
import '../../../../data/models/pet_model.dart'; // Import Model

class SignupController extends ChangeNotifier {
  // State
  int currentStep = 0;
  final int totalSteps = 7;
  bool isAddingAnotherPet = false;

  // Controllers
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Data
  File? ownerImageFile;
  File? petImageFile;
  String? selectedPetType;
  String? selectedGender;
  String? selectedBreed;
  DateTime? selectedDob;
  bool isSterilized = false;

  final ImagePicker _picker = ImagePicker();

  void init(bool isAddingPet) {
    isAddingAnotherPet = isAddingPet;
    if (isAddingPet) {
      currentStep = 2; // Skip owner details
    }
    notifyListeners();
  }

  Future<void> pickImage(bool isOwner) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      if (isOwner) {
        ownerImageFile = File(pickedFile.path);
      } else {
        petImageFile = File(pickedFile.path);
      }
      notifyListeners();
    }
  }

  void setPetType(String type) {
    selectedPetType = type;
    selectedBreed = null; // Reset breed on type change
    notifyListeners();
  }

  void setGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  void setBreed(String breed) {
    selectedBreed = breed;
    notifyListeners();
  }

  void setDob(DateTime date) {
    selectedDob = date;
    notifyListeners();
  }

  void toggleSterilized(bool value) {
    isSterilized = value;
    notifyListeners();
  }

  // --- NAVIGATION & VALIDATION ---
  bool validateCurrentStep(BuildContext context) {
    String? error;
    switch (currentStep) {
      case 0:
        if (ownerNameController.text.trim().isEmpty)
          error = "Please enter your name.";
        else if (emailController.text.trim().isEmpty)
          error = "Please enter your email.";
        else if (!emailController.text.contains('@'))
          error = "Enter a valid email.";
        break;
      case 1:
        if (passwordController.text.length < 6)
          error = "Password must be at least 6 chars.";
        break;
      case 2:
        if (selectedPetType == null) error = "Please select an Agent type.";
        break;
      case 3:
        if (petNameController.text.trim().isEmpty)
          error = "Please enter the Agent's name.";
        break;
      case 4:
        if (selectedDob == null) error = "Please select the birth date.";
        break;
      case 5:
        if (selectedBreed == null)
          error = "Please select a breed.";
        else if (weightController.text.trim().isEmpty)
          error = "Please enter the weight.";
        break;
      case 6:
        if (selectedGender == null) error = "Please select the gender.";
        break;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return false;
    }
    return true;
  }

  void nextStep(VoidCallback onComplete) {
    if (currentStep < totalSteps - 1) {
      currentStep++;
      notifyListeners();
    } else {
      onComplete();
    }
  }

  void prevStep(BuildContext context) {
    if (isAddingAnotherPet && currentStep == 2) {
      Navigator.pop(context);
    } else if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    } else {
      Navigator.pop(context);
    }
  }

  // --- FINAL SAVE ---
  Future<void> generateSmartCard() async {
    // 1. Save Owner Info
    if (!isAddingAnotherPet) {
      await DataService().setUserInfo(
        name: ownerNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        imagePath: ownerImageFile?.path,
      );
    }

    // 2. Create Agent
    final newPet = Pet(
      id: "#${(10000 + DateTime.now().millisecondsSinceEpoch % 90000)}",
      name: petNameController.text.trim(),
      type: selectedPetType!,
      breed: selectedBreed!,
      gender: selectedGender!,
      weight: (double.tryParse(weightController.text.trim()) ?? 0.0),
      dob: selectedDob!,
      image: petImageFile?.path ?? "assets/images/appLogo.png",
      isConnected: true,
      battery: 1.0,
    );

    await DataService().addPet(newPet);

    if (!isAddingAnotherPet) {
      await DataService().setLoginState(true);
    }
  }
}
