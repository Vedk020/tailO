import 'package:flutter/foundation.dart';
import '../../../core/services/data_service.dart';
import '../../../data/models/community_post.dart';

class CommunityViewModel extends ChangeNotifier {
  final DataService _dataService = DataService();

  // ✅ Fix: Explicitly return ValueNotifier or cast it correctly
  ValueNotifier<List<CommunityPost>> get posts => _dataService.postsNotifier;

  void likePost(String id) {
    _dataService.togglePostLike(id);
  }

  void createPost(String content, String? imagePath) {
    _dataService.addPost(content, image: imagePath);
  }
}
