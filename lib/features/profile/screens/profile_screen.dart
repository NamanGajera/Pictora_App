import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/post/models/post_data.dart';
import 'package:pictora/features/profile/bloc/profile_bloc.dart';
import 'package:pictora/utils/constants/bloc_instances.dart';
import 'package:pictora/utils/constants/colors.dart';
import 'package:pictora/utils/constants/constants.dart';
import 'package:pictora/utils/services/custom_logger.dart';

import '../../../model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    profileBloc.add(GetUserDataEvent(userId: widget.userId));
    if (widget.userId == null) {
      postBloc.add(GetMyPostEvent(body: {
        "skip": 0,
        "take": 25,
        "userId": userId,
      }));
    } else {
      postBloc.add(GetOtherUserPostsEvent(body: {
        "skip": 0,
        "take": 25,
        "userId": widget.userId,
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAF9),
      body: Column(
        children: [
          _buildProfileInfo(),
          // _buildTabBar(),
          Expanded(
            child: _buildPostsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => previous.getUserDataApiStatus != current.getUserDataApiStatus,
      builder: (context, state) {
        User? userData = widget.userId == null ? state.userData : state.otherUserData;
        return GestureDetector(
          onTap: () {
            logDebug(message: '${userData?.toJson()}', tag: "User Data Log");
          },
          child: Container(
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
                                primaryColor,
                                primaryColor.withValues(alpha: 0.6),
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
                              backgroundColor: primaryColor.withValues(alpha: 0.1),
                              child: (userData?.profile?.profilePicture ?? '').isNotEmpty
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: userData!.profile!.profilePicture!,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                        errorWidget: (context, url, error) => const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color(0xff235347),
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xff235347),
                                    ),
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
                          _buildStatItem('Posts', userData?.counts?.postCount ?? 0),
                          _buildStatItem('Followers', userData?.counts?.followerCount ?? 0),
                          _buildStatItem('Following', userData?.counts?.followingCount ?? 0),
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
                      userData?.fullName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Bio
                Text(
                  userData?.profile?.bio ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                _buildActionButtons(userData?.id ?? ''),
              ],
            ),
          ),
        );
      },
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

  Widget _buildActionButtons(String profileUserId) {
    if (profileUserId == userId) {
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
              'Following',
              backgroundColor: Colors.grey[200]!,
              textColor: Colors.black87,
              onTap: () {},
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

  Widget _buildPostsGrid() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: widget.userId == null ? state.myPostData?.length : state.otherUserPostData?.length,
          itemBuilder: (context, index) {
            final postData = widget.userId == null ? state.myPostData : state.otherUserPostData;
            return _buildPostPreview(postData?[index]);
          },
        );
      },
    );
  }

  Widget _buildPostPreview(PostData? post) {
    return GestureDetector(
      onTap: () {
        // Handle post tap
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: post?.mediaData?[0].mediaUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.image,
                color: primaryColor.withValues(alpha: 0.5),
                size: 30,
              ),
            ),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if ((post?.mediaData?.length ?? 0) > 1)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.copy_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
        ],
      ),
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

class ProfileScreenDataModel {
  final String? userId;
  ProfileScreenDataModel({this.userId});
}
