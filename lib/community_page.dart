import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'theme.dart';
import 'data_service.dart';
import 'pet_model.dart';
import 'create_post_page.dart';
import 'brand_footer.dart'; // Import Footer

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final GlobalKey _shareKey = GlobalKey();

  // --- COMMENT LOGIC ---
  void _showCommentDialog(BuildContext context, String postId) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add a Comment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Type something nice...",
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (commentController.text.trim().isNotEmpty) {
                      DataService().addPostComment(postId);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TailOColors.coral,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Post Comment",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SHARE LOGIC ---
  void _showShareOverlay(BuildContext context, CommunityPost post) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Share",
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sharing Story",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    RepaintBoundary(
                      key: _shareKey,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Material(
                          color: Colors.transparent,
                          child: _buildPostCard(
                            context,
                            post,
                            isForShare: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _captureAndShare(),
                        icon: const Icon(
                          LucideIcons.share,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Share Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TailOColors.coral,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
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
      },
    );
  }

  Future<void> _captureAndShare() async {
    try {
      RenderRepaintBoundary? boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File(
        '${directory.path}/tailo_story.png',
      ).create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(imagePath.path),
      ], text: 'Check out this story on #tailO! 🐾');
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostPage()),
          );
        },
        backgroundColor: TailOColors.coral,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: ValueListenableBuilder<List<CommunityPost>>(
        valueListenable: DataService().postsNotifier,
        builder: (context, posts, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Community",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Connect with other pet owners",
                    style: TextStyle(fontSize: 14, color: TailOColors.muted),
                  ),
                  const SizedBox(height: 24),

                  // Create Post Trigger
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePostPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            // Show current user's PFP
                            backgroundImage: DataService.getImageProvider(
                              DataService().ownerImage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Share your story...",
                            style: TextStyle(
                              color: TailOColors.muted,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            LucideIcons.image,
                            color: TailOColors.coral.withValues(alpha: 0.8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  Text(
                    "Recent Posts",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...posts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPostCard(context, post),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- ADD FOOTER HERE ---
                  const BrandFooter(),

                  const SizedBox(height: 60), // Extra space for FAB
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    CommunityPost post, {
    bool isForShare = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isForShare
        ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
        : theme.cardColor;
    final Color textColor = isForShare
        ? (isDark ? Colors.white : Colors.black)
        : theme.textTheme.bodyLarge!.color!;

    // Determine Avatar: If it's the current user, show their image. Else show generic app logo for demo users.
    final bool isCurrentUser = post.author == DataService().ownerName;
    final ImageProvider avatarImage = isCurrentUser
        ? DataService.getImageProvider(DataService().ownerImage)
        : const AssetImage('assets/images/appLogo.png');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: isForShare ? null : Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Author
          Row(
            children: [
              CircleAvatar(radius: 22, backgroundImage: avatarImage),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TailOColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isForShare)
                const Icon(
                  LucideIcons.moreVertical,
                  color: TailOColors.muted,
                  size: 20,
                ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 16,
              color: textColor.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),

          if (post.postImage != null && post.postImage!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: post.postImage!.startsWith('http')
                  ? Image.network(
                      post.postImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        height: 200,
                        color: Colors.grey.withValues(alpha: 0.1),
                        child: const Center(child: Icon(LucideIcons.imageOff)),
                      ),
                    )
                  : Image.file(
                      File(post.postImage!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
          ],

          const SizedBox(height: 20),

          // Watermark
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "#tail",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor.withValues(alpha: 0.3),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                "O",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: TailOColors.coral.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),

          if (!isForShare) ...[
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 8),
            // Functional Actions
            Row(
              children: [
                _actionButton(
                  icon: post.isLiked ? LucideIcons.heart : LucideIcons.heart,
                  color: post.isLiked ? Colors.red : TailOColors.muted,
                  count: "${post.likes}",
                  onTap: () => DataService().togglePostLike(post.id),
                ),
                const SizedBox(width: 24),
                _actionButton(
                  icon: LucideIcons.messageCircle,
                  count: "${post.comments}",
                  onTap: () => _showCommentDialog(context, post.id),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    LucideIcons.share2,
                    color: TailOColors.muted,
                    size: 20,
                  ),
                  onPressed: () => _showShareOverlay(context, post),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String count,
    required VoidCallback onTap,
    Color color = TailOColors.muted,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
