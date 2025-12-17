import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Required for picking images
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'data_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _controller = TextEditingController();

  // State to hold the real image file
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // --- PICK IMAGE FUNCTION ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // --- SUBMIT FUNCTION ---
  void _submit() {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    // Pass the real local path if an image exists
    String? imagePath = _selectedImage?.path;

    DataService().addPost(_controller.text.trim(), image: imagePath);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Story posted successfully!"),
        backgroundColor: TailOColors.coral,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: TailOColors.coral,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Post",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/pfp.jpeg'),
                ),
                const SizedBox(width: 12),
                Text(
                  DataService().ownerName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Text Field
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                autofocus: true,
                style: TextStyle(
                  fontSize: 18,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: const InputDecoration(
                  hintText: "Share your story with the community...",
                  hintStyle: TextStyle(color: TailOColors.muted),
                  border: InputBorder.none,
                ),
              ),
            ),

            // --- IMAGE PREVIEW ---
            if (_selectedImage != null)
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.x,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // --- ATTACHMENT BUTTONS ---
            Divider(color: theme.dividerColor),
            Row(
              children: [
                IconButton(
                  onPressed: _pickImage, // Calls real picker
                  icon: const Icon(
                    LucideIcons.imagePlus,
                    color: TailOColors.coral,
                  ),
                ),
                const Text(
                  "Add Photo",
                  style: TextStyle(
                    color: TailOColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
