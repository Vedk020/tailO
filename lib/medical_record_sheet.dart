import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'theme.dart';
import 'pet_model.dart';

class MedicalRecordSheet extends StatefulWidget {
  const MedicalRecordSheet({super.key});

  @override
  State<MedicalRecordSheet> createState() => _MedicalRecordSheetState();
}

class _MedicalRecordSheetState extends State<MedicalRecordSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = "Vet";

  // Image State
  bool _isUploading = false;
  File? _selectedImageFile;

  final List<Map<String, dynamic>> _types = [
    {'label': 'Vet', 'icon': LucideIcons.stethoscope},
    {'label': 'Vaccine', 'icon': LucideIcons.syringe},
    {'label': 'Meds', 'icon': LucideIcons.pill},
    {'label': 'Illness', 'icon': LucideIcons.thermometer},
    {'label': 'Weight', 'icon': LucideIcons.scale},
  ];

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // --- REAL IMAGE PICKER LOGIC ---
  Future<void> _pickImage() async {
    // 1. Request Permission
    // Note: Android 13+ uses photos permission, older uses storage
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.storage,
    ].request();

    // In a real app, check statuses. For simplicity in dev, we try picking anyway
    // because image_picker handles some permission logic internally on newer Androids.

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);

      // 2. Save Image Permanently
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(image.path);
      final File localImage = await File(
        image.path,
      ).copy('${directory.path}/$fileName');

      setState(() {
        _selectedImageFile = localImage;
        _isUploading = false;
      });
    }
  }

  void _removeFile() {
    setState(() => _selectedImageFile = null);
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

            // TYPE CHIPS
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
                children: _types.map((type) {
                  final isSelected = _selectedType == type['label'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(type['label']),
                      avatar: Icon(
                        type['icon'],
                        size: 16,
                        color: isSelected ? Colors.white : TailOColors.muted,
                      ),
                      selected: isSelected,
                      onSelected: (val) =>
                          setState(() => _selectedType = type['label']),
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

            // INPUTS
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
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    theme,
                    "Weight (kg)",
                    _weightController,
                    LucideIcons.scale,
                    isNumber: true,
                  ),
                ),
              ],
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

            // IMAGE UPLOADER
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
                        _isUploading ? "Please wait" : "Tap to open gallery",
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
                          const Text(
                            "Tap save to keep this.",
                            style: TextStyle(
                              fontSize: 12,
                              color: TailOColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.red),
                      onPressed: _removeFile,
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
                onPressed: () {
                  if (_titleController.text.isEmpty) return;
                  final newRecord = MedicalRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: _selectedType,
                    title: _titleController.text,
                    date: _selectedDate,
                    weight: _weightController.text,
                    notes: _notesController.text,
                    attachmentPath: _selectedImageFile?.path, // Save the path!
                  );
                  Navigator.pop(context, newRecord);
                },
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
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
