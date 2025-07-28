import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../post/models/post_details_model.dart';
import '../../post/screens/post_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data for posts
  final List<PostModel> posts = [
    PostModel(
      id: '1',
      username: 'john_doe',
      userAvatar: 'https://via.placeholder.com/40',
      timeAgo: '2h',
      caption: 'Beautiful sunset at the beach! 🌅 #sunset #beach #photography',
      mediaUrls: [
        'https://via.placeholder.com/400x300',
        'https://via.placeholder.com/400x300/FF0000',
        'https://via.placeholder.com/400x300/00FF00',
      ],
      likes: 1234,
      isLiked: false,
      isSaved: false,
      comments: 56,
    ),
    PostModel(
      id: '2',
      username: 'sarah_smith',
      userAvatar: 'https://via.placeholder.com/40',
      timeAgo: '4h',
      caption: 'Morning coffee vibes ☕️ Starting the day right!',
      mediaUrls: [
        'https://via.placeholder.com/400x300/FFA500',
      ],
      likes: 892,
      isLiked: true,
      isSaved: true,
      comments: 23,
    ),
    PostModel(
      id: '3',
      username: 'travel_diaries',
      userAvatar: 'https://via.placeholder.com/40',
      timeAgo: '6h',
      caption:
          'Exploring the mountains! The view from up here is incredible. Nature never fails to amaze me 🏔️⛰️ #mountains #hiking #nature #adventure',
      mediaUrls: [
        'https://via.placeholder.com/400x300/87CEEB',
        'https://via.placeholder.com/400x300/90EE90',
      ],
      likes: 2156,
      isLiked: false,
      isSaved: false,
      comments: 89,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Handle refresh
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          itemCount: posts.length,
          padding: EdgeInsets.symmetric(horizontal: 6),
          itemBuilder: (context, index) {
            return PostWidget(
              post: posts[index],
              onLike: (postId) => _handleLike(postId),
              onSave: (postId) => _handleSave(postId),
              onComment: (postId) => _handleComment(postId),
              onShare: (postId) => _handleShare(postId),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Pictora',
        style: TextStyle(
          color: primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: primaryColor),
          onPressed: () {
            // Handle notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.send_outlined, color: primaryColor),
          onPressed: () {
            // Handle messages
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _handleLike(String postId) {
    setState(() {
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex].isLiked = !posts[postIndex].isLiked;
        posts[postIndex].likes += posts[postIndex].isLiked ? 1 : -1;
      }
    });
  }

  void _handleSave(String postId) {
    setState(() {
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        posts[postIndex].isSaved = !posts[postIndex].isSaved;
      }
    });
  }

  void _handleComment(String postId) {
    // Navigate to comments screen
    print('Comment on post: $postId');
  }

  void _handleShare(String postId) {
    // Handle share functionality
    print('Share post: $postId');
  }
}
