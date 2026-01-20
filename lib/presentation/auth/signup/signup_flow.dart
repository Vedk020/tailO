import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Core
import '../../../core/theme/colors.dart';
import '../../../core/services/data_service.dart';
import '../../home/main_scaffold.dart';
import '../../../data/models/pet_model.dart'; // Import Pet Model

// Steps (Ensure these files exist in signup_steps folder)
import 'signup_steps/owner_step.dart';
import 'signup_steps/pet_type_step.dart';

class SignupFlow extends StatefulWidget {
  final bool isAddingAnotherPet;
  const SignupFlow({super.key, this.isAddingAnotherPet = false});

  @override
  State<SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<SignupFlow> {
  int _currentStep = 0;
  bool _isLoading = false;

  // --- FORM STATE ---
  // Owner (Only if not adding another pet)
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Pet
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = "Male";
  DateTime _selectedDob = DateTime.now();
  File? _selectedImage;

  // Custom Enum for local UI logic (matches your Step files)
  PetType _selectedType = PetType.dog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // If adding another pet, skip Owner Step (Step 0)
    final int effectiveStep = widget.isAddingAnotherPet
        ? _currentStep + 1
        : _currentStep;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.iconTheme.color),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          "Step ${effectiveStep + 1} of ${widget.isAddingAnotherPet ? 2 : 3}",
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (effectiveStep + 1) / (widget.isAddingAnotherPet ? 2 : 3),
            backgroundColor: theme.dividerColor,
            color: TailOColors.coral,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TailOColors.coral,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLastStep() ? "Finish" : "Next",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    // If adding another pet, we treat our internal step 0 as the "Pet Type" step
    // Internal Logic:
    // Case A (New User): Step 0 = Owner, Step 1 = Type, Step 2 = Details
    // Case B (Add Pet):  Step 0 = Type,  Step 1 = Details

    if (widget.isAddingAnotherPet) {
      if (_currentStep == 0) return _buildPetTypeStep();
      return _buildPetDetailsStep();
    } else {
      if (_currentStep == 0) return _buildOwnerStep();
      if (_currentStep == 1) return _buildPetTypeStep();
      return _buildPetDetailsStep();
    }
  }

  // --- STEPS UI ---
  // (Assuming you have these widgets in separate files, I'll inline simplified versions to ensure it compiles)

  Widget _buildOwnerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Let's get to know you",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildTextField("Your Name", _ownerNameController),
        const SizedBox(height: 16),
        _buildTextField("Email", _ownerEmailController),
        const SizedBox(height: 16),
        _buildTextField("Password", _passwordController, isObscure: true),
      ],
    );
  }

  Widget _buildPetTypeStep() {
    return Column(
      children: [
        const Text(
          "What kind of pet do you have?",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildTypeCard(PetType.dog, "Dog", LucideIcons.dog),
            const SizedBox(width: 16),
            _buildTypeCard(PetType.cat, "Cat", LucideIcons.cat),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard(PetType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: isSelected
                ? TailOColors.coral.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? TailOColors.coral
                  : Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? TailOColors.coral : TailOColors.muted,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? TailOColors.coral : TailOColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).cardColor,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : null,
              child: _selectedImage == null
                  ? const Icon(
                      LucideIcons.camera,
                      size: 30,
                      color: TailOColors.muted,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField("Pet's Name", _nameController),
        const SizedBox(height: 16),
        _buildTextField("Breed", _breedController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                "Weight (kg)",
                _weightController,
                isNumber: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    "Birthday",
                    TextEditingController(
                      text:
                          "${_selectedDob.day}/${_selectedDob.month}/${_selectedDob.year}",
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }

  // --- ACTIONS ---

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  bool _isLastStep() {
    if (widget.isAddingAnotherPet) return _currentStep == 1;
    return _currentStep == 2;
  }

  void _onNext() {
    if (_isLastStep()) {
      _finishSetup();
    } else {
      setState(() => _currentStep++);
    }
  }

  void _finishSetup() async {
    setState(() => _isLoading = true);

    try {
      // 1. Save Owner Info (Only if new user)
      if (!widget.isAddingAnotherPet) {
        await DataService().setUserInfo(
          name: _ownerNameController.text.trim(),
          email: _ownerEmailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      // 2. Create Pet Object
      final newPet = Pet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType.name,
        breed: _breedController.text.trim(),
        gender: _selectedGender,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        dob: _selectedDob,
        image: _selectedImage?.path ?? 'assets/images/appLogo.png',
        isConnected: false,
      );

      // 3. Save Pet
      await DataService().addPet(newPet);

      // 4. Set Login State
      await DataService().setLoginState(true);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }
}

// Simple Enum for local UI state
enum PetType { dog, cat }
