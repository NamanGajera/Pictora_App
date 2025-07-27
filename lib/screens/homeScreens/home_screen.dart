import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

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

class PostWidget extends StatefulWidget {
  final PostModel post;
  final Function(String) onLike;
  final Function(String) onSave;
  final Function(String) onComment;
  final Function(String) onShare;

  const PostWidget({
    super.key,
    required this.post,
    required this.onLike,
    required this.onSave,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  PageController pageController = PageController();
  int currentMediaIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          _buildMediaSection(),
          _buildActionButtons(),
          _buildLikesSection(),
          _buildCaptionSection(),
          _buildCommentsSection(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Enhanced profile picture with gradient border
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withOpacity(0.1),
                backgroundImage: widget.post.userAvatar.isNotEmpty
                    ? NetworkImage(widget.post.userAvatar)
                    : null,
                child: widget.post.userAvatar.isEmpty
                    ? const Icon(Icons.person, color: primaryColor, size: 20)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Verified badge (optional)
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.post.timeAgo,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.public,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Public',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Enhanced more options button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, size: 20),
              color: Colors.grey[600],
              onPressed: () {
                _showPostOptions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentMediaIndex = index;
              });
            },
            itemCount: widget.post.mediaUrls.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                height: 320,
                color: Colors.grey[100],
                child: Image.network(
                  widget.post.mediaUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: primaryColor.withOpacity(0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 50,
                            color: primaryColor.withOpacity(0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Photo ${index + 1}',
                            style: TextStyle(
                              color: primaryColor.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Simple media counter
          if (widget.post.mediaUrls.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentMediaIndex + 1}/${widget.post.mediaUrls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Clean dots indicator
          if (widget.post.mediaUrls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.post.mediaUrls.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: currentMediaIndex == index ? 8 : 6,
                    height: currentMediaIndex == index ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentMediaIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onLike(widget.post.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.post.isLiked ? Colors.red : Colors.black87,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => widget.onComment(widget.post.id),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.black87,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => widget.onShare(widget.post.id),
            child: const Icon(
              Icons.send_outlined,
              color: Colors.black87,
              size: 26,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => widget.onSave(widget.post.id),
            child: Icon(
              widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: widget.post.isSaved ? primaryColor : Colors.black87,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '${_formatNumber(widget.post.likes)} likes',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCaptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${widget.post.username} ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: widget.post.caption,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => widget.onComment(widget.post.id),
        child: Text(
          'View all ${widget.post.comments} comments',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetOption(
                icon: Icons.link,
                title: 'Copy Link',
                onTap: () {
                  Navigator.pop(context);
                  // Handle copy link
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.report_outlined,
                title: 'Report',
                onTap: () {
                  Navigator.pop(context);
                  // Handle report
                },
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Post Model
class PostModel {
  final String id;
  final String username;
  final String userAvatar;
  final String timeAgo;
  final String caption;
  final List<String> mediaUrls;
  int likes;
  bool isLiked;
  bool isSaved;
  final int comments;

  PostModel({
    required this.id,
    required this.username,
    required this.userAvatar,
    required this.timeAgo,
    required this.caption,
    required this.mediaUrls,
    required this.likes,
    required this.isLiked,
    required this.isSaved,
    required this.comments,
  });
}
