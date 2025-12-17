import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'main.dart';
import 'pet_model.dart';
import 'data_service.dart';

class SignupFlow extends StatefulWidget {
  final bool isAddingAnotherPet;
  const SignupFlow({super.key, this.isAddingAnotherPet = false});

  @override
  State<SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<SignupFlow> {
  int _currentStep = 0;
  final int _totalSteps = 7;

  // Input Controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Selection Data
  String? _selectedPetType;
  String? _selectedGender;
  String? _selectedBreed;
  DateTime? _selectedDob;
  bool _isSterilized = false;

  // Pre-filled Breeds
  final List<String> _dogBreeds = [
    "Golden Retriever",
    "German Shepherd",
    "Labrador",
    "Bulldog",
    "Poodle",
    "Beagle",
    "Rottweiler",
    "Dachshund",
    "Pug",
    "Husky",
    "Boxer",
    "Shih Tzu",
    "Other",
  ];

  final List<String> _catBreeds = [
    "Persian",
    "Siamese",
    "Maine Coon",
    "Ragdoll",
    "Bengal",
    "Sphynx",
    "British Shorthair",
    "Abyssinian",
    "Scottish Fold",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    // If adding another agent from inside the app, skip Owner Details & Password
    if (widget.isAddingAnotherPet) {
      _currentStep = 2;
    }
  }

  // --- NAVIGATION LOGIC ---
  void _nextStep() {
    String? error;

    switch (_currentStep) {
      case 0: // Owner Info
        if (_ownerNameController.text.trim().isEmpty)
          error = "Please enter your name.";
        else if (_emailController.text.trim().isEmpty)
          error = "Please enter your email.";
        else if (!_emailController.text.contains('@'))
          error = "Enter a valid email.";
        break;
      case 1: // Password
        if (_passwordController.text.length < 6)
          error = "Password must be at least 6 chars.";
        break;
      case 2: // Type
        if (_selectedPetType == null) error = "Please select an Agent type.";
        break;
      case 3: // Name
        if (_petNameController.text.trim().isEmpty)
          error = "Please enter the Agent's name.";
        break;
      case 4: // DOB
        if (_selectedDob == null) error = "Please select the birth date.";
        break;
      case 5: // Details (Breed & Weight)
        if (_selectedBreed == null)
          error = "Please select a breed.";
        else if (_weightController.text.trim().isEmpty)
          error = "Please enter the weight.";
        break;
      case 6: // Gender
        if (_selectedGender == null) error = "Please select the gender.";
        break;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _generateSmartCard();
    }
  }

  void _prevStep() {
    if (widget.isAddingAnotherPet && _currentStep == 2) {
      Navigator.pop(context);
    } else if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  // --- DATE PICKER ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: TailOColors.coral,
              onPrimary: Colors.white,
              surface: Color(0xFF1C1C1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  // --- SAVE & FINISH ---
  void _generateSmartCard() async {
    // 1. Save Owner Info (If new signup)
    if (!widget.isAddingAnotherPet) {
      await DataService().setUserInfo(
        name: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(), // <--- SAVING PASSWORD HERE
      );
    }

    // 2. Create the new Agent
    final newPet = Pet(
      id: "#${(10000 + DateTime.now().millisecondsSinceEpoch % 90000)}",
      name: _petNameController.text.trim(),
      type: _selectedPetType!,
      breed: _selectedBreed!,
      gender: _selectedGender!,
      weight: "${_weightController.text.trim()} kg",
      dob: _selectedDob!,
      image: "assets/images/appLogo.png",
      isConnected: true,
      battery: 1.0,
    );

    await DataService().addPet(newPet);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: TailOColors.coral),
              SizedBox(height: 20),
              Text(
                "Generating SmartCard...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.pop(context);
      if (widget.isAddingAnotherPet) {
        Navigator.pop(context);
      } else {
        await DataService().setLoginState(true);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScaffold()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      color: theme.iconTheme.color,
                    ),
                    onPressed: _prevStep,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.dividerColor,
                        color: TailOColors.coral,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(theme),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: theme.dividerColor)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TailOColors.coral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentStep == _totalSteps - 1
                        ? "GENERATE CARD"
                        : "CONTINUE",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildMascotStep(
          theme,
          "Welcome to the Agency! Who are we working with?",
          Column(
            children: [
              _buildTextField(
                theme,
                "Your Name",
                _ownerNameController,
                LucideIcons.user,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                theme,
                "Email Address",
                _emailController,
                LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        );
      case 1:
        return _buildMascotStep(
          theme,
          "Great! Now create a secure password.",
          _buildTextField(
            theme,
            "Password",
            _passwordController,
            LucideIcons.lock,
            isObscure: true,
          ),
        );
      case 2:
        return _buildMascotStep(
          theme,
          "Choose your Agent type!",
          Row(
            children: [
              Expanded(
                child: _buildSelectableCard(
                  theme,
                  "Dog",
                  LucideIcons.dog,
                  _selectedPetType == 'dog',
                  () => setState(() {
                    _selectedPetType = 'dog';
                    _selectedBreed = null;
                  }),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectableCard(
                  theme,
                  "Cat",
                  LucideIcons.cat,
                  _selectedPetType == 'cat',
                  () => setState(() {
                    _selectedPetType = 'cat';
                    _selectedBreed = null;
                  }),
                ),
              ),
            ],
          ),
        );
      case 3:
        return _buildMascotStep(
          theme,
          "What is your ${_selectedPetType ?? 'agent'}'s name?",
          _buildTextField(
            theme,
            "Agent Name",
            _petNameController,
            LucideIcons.pencil,
          ),
        );
      case 4:
        return _buildMascotStep(
          theme,
          "When is ${_petNameController.text.isEmpty ? 'their' : _petNameController.text}'s birthday?",
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDob == null
                        ? "Select Date"
                        : "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}",
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Icon(LucideIcons.calendar, color: TailOColors.coral),
                ],
              ),
            ),
          ),
        );
      case 5:
        return _buildMascotStep(
          theme,
          "Tell us more details about your agent.",
          Column(
            children: [
              _buildDropdownField(
                theme,
                "Select Breed",
                _selectedPetType == 'cat' ? _catBreeds : _dogBreeds,
                LucideIcons.dna,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                theme,
                "Weight (kg)",
                _weightController,
                LucideIcons.scale,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        );
      case 6:
        return _buildMascotStep(
          theme,
          "Almost done! Gender & Sterilization.",
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSelectableCard(
                      theme,
                      "Male",
                      LucideIcons.moveUpRight,
                      _selectedGender == 'Male',
                      () => setState(() => _selectedGender = 'Male'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSelectableCard(
                      theme,
                      "Female",
                      LucideIcons.moveDownLeft,
                      _selectedGender == 'Female',
                      () => setState(() => _selectedGender = 'Female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: SwitchListTile(
                  title: Text(
                    "Sterilized?",
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  ),
                  activeColor: TailOColors.coral,
                  value: _isSterilized,
                  onChanged: (val) => setState(() => _isSterilized = val),
                ),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildMascotStep(ThemeData theme, String speech, Widget content) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/appLogo.png', height: 100, width: 100),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  speech,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        content,
      ],
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isObscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 18, color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: TailOColors.muted),
          hintText: hint,
          hintStyle: const TextStyle(color: TailOColors.muted),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    ThemeData theme,
    String hint,
    List<String> items,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedBreed,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: TailOColors.muted),
          hintText: hint,
          hintStyle: const TextStyle(color: TailOColors.muted),
        ),
        dropdownColor: theme.cardColor,
        style: TextStyle(fontSize: 18, color: theme.textTheme.bodyLarge?.color),
        icon: const Icon(LucideIcons.chevronDown, color: TailOColors.muted),
        items: items
            .map(
              (String value) =>
                  DropdownMenuItem<String>(value: value, child: Text(value)),
            )
            .toList(),
        onChanged: (newValue) => setState(() => _selectedBreed = newValue),
      ),
    );
  }

  Widget _buildSelectableCard(
    ThemeData theme,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? TailOColors.coral.withValues(alpha: 0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TailOColors.coral : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? TailOColors.coral : TailOColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? TailOColors.coral
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
