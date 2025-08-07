import 'package:flutter/material.dart';

class LikedByUserScreen extends StatefulWidget {
  final String postId;
  const LikedByUserScreen({
    super.key,
    required this.postId,
  });

  @override
  State<LikedByUserScreen> createState() => _LikedByUserScreenState();
}

class _LikedByUserScreenState extends State<LikedByUserScreen> {
  static const primaryColor = Color(0xff235347);
  List<UserLike> likedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLikedUsers();
  }

  Future<void> _loadLikedUsers() async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 1000));

    // Mock data - replace with your actual API call
    setState(() {
      likedUsers = [
        UserLike(
          userId: "1",
          userName: "john_doe",
          userFullName: "John Doe",
          userProfileImage: "https://via.placeholder.com/150",
          isFollowing: false,
        ),
        UserLike(
          userId: "2",
          userName: "jane_smith",
          userFullName: "Jane Smith",
          userProfileImage: "https://via.placeholder.com/150",
          isFollowing: true,
        ),
        UserLike(
          userId: "3",
          userName: "mike_wilson",
          userFullName: "Mike Wilson",
          userProfileImage: "https://via.placeholder.com/150",
          isFollowing: false,
        ),
        UserLike(
          userId: "4",
          userName: "sarah_taylor",
          userFullName: "Sarah Taylor",
          userProfileImage: "https://via.placeholder.com/150",
          isFollowing: true,
        ),
        UserLike(
          userId: "5",
          userName: "alex_brown",
          userFullName: "Alex Brown",
          userProfileImage: "https://via.placeholder.com/150",
          isFollowing: false,
        ),
      ];
      isLoading = false;
    });
  }

  void _toggleFollow(String userId) {
    setState(() {
      final userIndex = likedUsers.indexWhere((user) => user.userId == userId);
      if (userIndex != -1) {
        likedUsers[userIndex].isFollowing = !likedUsers[userIndex].isFollowing;
      }
    });

    // TODO: Implement actual follow/unfollow API call
    print('Toggle follow for user: $userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Likes",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? _buildLoadingState()
          : likedUsers.isEmpty
              ? _buildEmptyState()
              : _buildUsersList(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "No likes yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "When people like this post,\nyou'll see them here",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: likedUsers.length,
      itemBuilder: (context, index) {
        final user = likedUsers[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(UserLike user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: ClipOval(
              child: user.userProfileImage.isNotEmpty
                  ? Image.network(
                      user.userProfileImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(user.userFullName);
                      },
                    )
                  : _buildDefaultAvatar(user.userFullName),
            ),
          ),

          SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.userFullName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Follow/Unfollow Button
          _buildFollowButton(user),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String fullName) {
    final initials = fullName.split(' ').take(2).map((name) => name.isNotEmpty ? name[0].toUpperCase() : '').join();

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(UserLike user) {
    return GestureDetector(
      onTap: () => _toggleFollow(user.userId),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: user.isFollowing ? Colors.grey[100] : primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: user.isFollowing ? Border.all(color: Colors.grey[300]!, width: 1) : null,
        ),
        child: Text(
          user.isFollowing ? "Following" : "Follow",
          style: TextStyle(
            color: user.isFollowing ? Colors.black87 : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class LikedByUserScreenDataModel {
  final String postId;
  LikedByUserScreenDataModel({
    required this.postId,
  });
}

class UserLike {
  final String userId;
  final String userName;
  final String userFullName;
  final String userProfileImage;
  bool isFollowing;

  UserLike({
    required this.userId,
    required this.userName,
    required this.userFullName,
    required this.userProfileImage,
    required this.isFollowing,
  });
}
