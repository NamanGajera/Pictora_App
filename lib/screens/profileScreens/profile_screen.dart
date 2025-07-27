import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFollowing = false;
  bool isOwnProfile = true; // Set to false for other user's profile

  // Sample user data
  final UserProfile userProfile = UserProfile(
    username: 'john_doe',
    displayName: 'John Doe',
    bio:
        '📸 Photography enthusiast\n🌍 Travel lover\n☕ Coffee addict\n📍 New York, USA',
    profileImage: 'https://via.placeholder.com/150',
    coverImage: 'https://via.placeholder.com/400x200',
    postsCount: 156,
    followersCount: 2847,
    followingCount: 1205,
    isVerified: true,
    website: 'john-photography.com',
  );

  // Sample posts data
  final List<PostPreview> userPosts = List.generate(
    24,
    (index) => PostPreview(
      id: index.toString(),
      imageUrl: 'https://via.placeholder.com/300x300',
      likesCount: (index + 1) * 45,
      commentsCount: (index + 1) * 12,
      hasMultipleMedia: index % 3 == 0,
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAF9),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
          ];
        },
        body: Column(
          children: [
            _buildProfileInfo(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsGrid(),
                  _buildReelsGrid(),
                  _buildTaggedGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xff235347),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isOwnProfile) ...[
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            onPressed: () {
              // Handle create post
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _showProfileOptions();
            },
          ),
        ] else
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showUserOptions();
            },
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover photo
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xff235347),
                    const Color(0xff235347).withOpacity(0.8),
                  ],
                ),
              ),
              child: userProfile.coverImage.isNotEmpty
                  ? Image.network(
                      userProfile.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xff235347),
                                const Color(0xff235347).withOpacity(0.7),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : null,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture and stats
          Row(
            children: [
              // Profile picture
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xff235347),
                          const Color(0xff235347).withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor:
                            const Color(0xff235347).withOpacity(0.1),
                        backgroundImage: userProfile.profileImage.isNotEmpty
                            ? NetworkImage(userProfile.profileImage)
                            : null,
                        child: userProfile.profileImage.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xff235347),
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (isOwnProfile)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xff235347),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 30),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Posts', userProfile.postsCount),
                    _buildStatItem('Followers', userProfile.followersCount),
                    _buildStatItem('Following', userProfile.followingCount),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name and verification
          Row(
            children: [
              Text(
                userProfile.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (userProfile.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified,
                  color: Color(0xff235347),
                  size: 18,
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Bio
          Text(
            userProfile.bio,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          if (userProfile.website.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Handle website tap
              },
              child: Text(
                userProfile.website,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff235347),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return GestureDetector(
      onTap: () {
        // Handle stat tap (navigate to followers/following list)
      },
      child: Column(
        children: [
          Text(
            _formatNumber(count),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (isOwnProfile) {
      return Row(
        children: [
          Expanded(
            child: _buildButton(
              'Edit Profile',
              backgroundColor: Colors.grey[100]!,
              textColor: Colors.black87,
              onTap: () {
                // Handle edit profile
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildButton(
              'Share Profile',
              backgroundColor: Colors.grey[100]!,
              textColor: Colors.black87,
              onTap: () {
                // Handle share profile
              },
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildButton(
              isFollowing ? 'Following' : 'Follow',
              backgroundColor:
                  isFollowing ? Colors.grey[200]! : const Color(0xff235347),
              textColor: isFollowing ? Colors.black87 : Colors.white,
              onTap: () {
                setState(() {
                  isFollowing = !isFollowing;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildButton(
              'Message',
              backgroundColor: Colors.grey[100]!,
              textColor: Colors.black87,
              onTap: () {
                // Handle message
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildButton(
    String text, {
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xff235347),
        indicatorWeight: 2,
        labelColor: const Color(0xff235347),
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(
            icon: Icon(Icons.grid_on),
          ),
          Tab(
            icon: Icon(Icons.video_collection_outlined),
          ),
          Tab(
            icon: Icon(Icons.person_pin_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        return _buildPostPreview(userPosts[index]);
      },
    );
  }

  Widget _buildPostPreview(PostPreview post) {
    return GestureDetector(
      onTap: () {
        // Handle post tap
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.grey[200],
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xff235347).withOpacity(0.1),
                  child: Icon(
                    Icons.image,
                    color: const Color(0xff235347).withOpacity(0.5),
                    size: 30,
                  ),
                );
              },
            ),
          ),
          if (post.hasMultipleMedia)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.copy_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          // Hover overlay for likes/comments (optional)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.transparent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(post.likesCount),
                      style: const TextStyle(
                        color: Colors.transparent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.chat_bubble,
                      color: Colors.transparent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(post.commentsCount),
                      style: const TextStyle(
                        color: Colors.transparent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsGrid() {
    return const Center(
      child: Text(
        'Reels\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTaggedGrid() {
    return const Center(
      child: Text(
        'Tagged Posts\nComing Soon',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showProfileOptions() {
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
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.archive_outlined,
                title: 'Archive',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.history,
                title: 'Your Activity',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserOptions() {
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
                icon: Icons.block,
                title: 'Block',
                onTap: () {
                  Navigator.pop(context);
                },
                isDestructive: true,
              ),
              _buildBottomSheetOption(
                icon: Icons.report,
                title: 'Report',
                onTap: () {
                  Navigator.pop(context);
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

// Models
class UserProfile {
  final String username;
  final String displayName;
  final String bio;
  final String profileImage;
  final String coverImage;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final String website;

  UserProfile({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.profileImage,
    required this.coverImage,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.isVerified,
    required this.website,
  });
}

class PostPreview {
  final String id;
  final String imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool hasMultipleMedia;

  PostPreview({
    required this.id,
    required this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.hasMultipleMedia,
  });
}
