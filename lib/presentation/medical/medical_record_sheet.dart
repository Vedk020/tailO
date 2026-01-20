import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Core
import '../../core/theme/colors.dart';
import '../../data/models/pet_model.dart';
// Note: Assuming you added the Enum above to your project structure
import '../../data/models/medical_record_type.dart';

class MedicalRecordSheet extends StatefulWidget {
  const MedicalRecordSheet({super.key});

  @override
  State<MedicalRecordSheet> createState() => _MedicalRecordSheetState();
}

class _MedicalRecordSheetState extends State<MedicalRecordSheet> {
  // Input Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State
  DateTime _selectedDate = DateTime.now();
  MedicalRecordType _selectedType = MedicalRecordType.vet;

  // Image State
  bool _isUploading = false;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  // Constants
  static const int _maxFileSizeMB = 5;

  @override
  void dispose() {
    _titleController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: now, // ✅ Prevent Future Dates
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Optimize logic
      );

      if (image != null) {
        setState(() => _isUploading = true);

        // 1. ✅ Validate Size
        final int sizeInBytes = await image.length();
        final double sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > _maxFileSizeMB) {
          _showError("Image is too large. Max size is 5MB.");
          setState(() => _isUploading = false);
          return;
        }

        // 2. ✅ Validate Extension (Basic Mime Check)
        final ext = path.extension(image.path).toLowerCase();
        if (!['.jpg', '.jpeg', '.png', '.pdf'].contains(ext)) {
          _showError("Unsupported file format. Use JPG or PNG.");
          setState(() => _isUploading = false);
          return;
        }

        // 3. Save to App Storage
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = "${DateTime.now().millisecondsSinceEpoch}$ext";
        final String localPath = path.join(directory.path, fileName);

        // Copy file to app storage so it persists
        await image.saveTo(localPath);

        if (mounted) {
          setState(() {
            _selectedImageFile = File(localPath);
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      _showError("Failed to attach image. Please try again.");
      setState(() => _isUploading = false);
    }
  }

  void _save() {
    // 1. Validate Required Fields
    if (_titleController.text.trim().isEmpty) {
      _showError("Please enter a title.");
      return;
    }

    // 2. Create Model
    final newRecord = MedicalRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType.label, // Or store Enum index if you refactor Model
      title: _titleController.text.trim(),
      date: _selectedDate,
      // Parse weight safely, assuming Model uses String for weight field or double
      // Adjust based on your final PetModel definition.
      // If MedicalRecord.weight is String?:
      weightSnapshot: double.tryParse(_weightController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      attachmentPath: _selectedImageFile?.path,
    );

    // 3. Return Logic
    Navigator.pop(context, newRecord);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: TailOColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TailOColors.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "Log Health Record",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),

            // TYPE SELECTOR
            Text(
              "Record Type",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TailOColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MedicalRecordType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(type.label),
                      avatar: Icon(
                        type.icon,
                        size: 16,
                        color: isSelected ? Colors.white : TailOColors.muted,
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedType = type);
                      },
                      backgroundColor: theme.cardColor,
                      selectedColor: TailOColors.coral,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyLarge?.color,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? TailOColors.coral
                              : theme.dividerColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // FORM FIELDS
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    theme,
                    "Title (e.g. Rabies)",
                    _titleController,
                    LucideIcons.pencil,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${_selectedDate.day}/${_selectedDate.month}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.calendar,
                            size: 18,
                            color: TailOColors.coral,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildTextField(
              theme,
              "Weight (kg)",
              _weightController,
              LucideIcons.scale,
              isNumber: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              theme,
              "Notes / Prescription",
              _notesController,
              LucideIcons.fileText,
              lines: 3,
            ),

            const SizedBox(height: 24),

            // IMAGE ATTACHMENT
            if (_selectedImageFile == null)
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.dividerColor,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: theme.cardColor.withValues(alpha: 0.5),
                  ),
                  child: Column(
                    children: [
                      _isUploading
                          ? const SizedBox(
                              height: 32,
                              width: 32,
                              child: CircularProgressIndicator(
                                color: TailOColors.coral,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              LucideIcons.uploadCloud,
                              size: 32,
                              color: TailOColors.muted,
                            ),
                      const SizedBox(height: 8),
                      Text(
                        _isUploading
                            ? "Processing..."
                            : "Upload Prescription or Report",
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isUploading
                            ? "Please wait"
                            : "Tap to open gallery (Max 5MB)",
                        style: const TextStyle(
                          fontSize: 12,
                          color: TailOColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                  color: theme.cardColor,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImageFile!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Image Attached",
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${(_selectedImageFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB",
                            style: const TextStyle(
                              fontSize: 12,
                              color: TailOColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.red),
                      onPressed: () =>
                          setState(() => _selectedImageFile = null),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TailOColors.coral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Save Record",
                  style: TextStyle(
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
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int lines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: lines,
        keyboardType: isNumber
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: TailOColors.muted, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: TailOColors.muted),
        ),
      ),
    );
  }
}
