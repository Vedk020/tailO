import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // REQUIRED
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/data_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;

  // Constants
  static const int _maxChars = 280;
  static const int _maxFileSizeMB = 5;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update UI state
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // --- IMAGE LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Optimize quality
      );

      if (pickedFile != null) {
        // ✅ VALIDATION: Check File Size
        final int sizeInBytes = await pickedFile.length();
        final double sizeInMB = sizeInBytes / (1024 * 1024);

        if (sizeInMB > _maxFileSizeMB) {
          if (mounted) {
            _showError("Image is too large. Max size is ${_maxFileSizeMB}MB.");
          }
          return;
        }

        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showError("Failed to pick image: $e");
    }
  }

  // --- POST ACTION ---
  void _post() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);

    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 1));

    // Save to DataService
    DataService().addPost(text, image: _selectedImage?.path);

    if (mounted) {
      setState(() => _isPosting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Posted successfully!"),
          backgroundColor: TailOColors.success,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: TailOColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canPost = _textController.text.trim().isNotEmpty && !_isPosting;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create Post"),
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Post Button
          TextButton(
            onPressed: canPost ? _post : null,
            child: _isPosting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    "Post",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canPost
                          ? TailOColors.coral
                          : TailOColors.muted.withValues(alpha: 0.5),
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: DataService.getImageProvider(
                    DataService().ownerImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: 5,
                    maxLength: _maxChars, // ✅ VALIDATION: Visual Limit
                    decoration: const InputDecoration(
                      hintText: "What's happening with your pet?",
                      border: InputBorder.none,
                      counterText: "", // Hide default counter
                    ),
                  ),
                ),
              ],
            ),

            // Image Preview
            if (_selectedImage != null) ...[
              const SizedBox(height: 20),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: const CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 14,
                        child: Icon(
                          LucideIcons.x,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // Character Counter
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${_textController.text.length} / $_maxChars",
                style: TextStyle(
                  fontSize: 12,
                  color: _textController.text.length >= _maxChars
                      ? TailOColors.error
                      : TailOColors.muted,
                ),
              ),
            ),

            Divider(color: theme.dividerColor),

            // Action Bar
            Row(
              children: [
                IconButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(LucideIcons.image, color: TailOColors.coral),
                  tooltip: "Gallery",
                ),
                IconButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(
                    LucideIcons.camera,
                    color: TailOColors.muted,
                  ),
                  tooltip: "Camera",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
