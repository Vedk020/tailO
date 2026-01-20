import 'package:flutter/foundation.dart';

class CommunityPost {
  final String id;
  final String author;
  final DateTime timestamp;
  final String content;
  final String? postImage;
  final int likes;
  final int comments;
  final bool isLiked;

  const CommunityPost({
    required this.id,
    required this.author,
    required this.timestamp,
    required this.content,
    this.postImage,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  // --- HELPER: Time Ago String ---
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  // --- SERIALIZATION ---
  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      author: json['author'] as String,
      timestamp: DateTime.parse(json['timestamp']),
      content: json['content'] as String,
      postImage: json['postImage'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'timestamp': timestamp.toIso8601String(),
      'content': content,
      'postImage': postImage,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
    };
  }

  // --- IMMUTABILITY (For State Updates) ---
  CommunityPost copyWith({
    String? id,
    String? author,
    DateTime? timestamp,
    String? content,
    String? postImage,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      author: author ?? this.author,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      postImage: postImage ?? this.postImage,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
