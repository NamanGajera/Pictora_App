import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/profile/screens/profile_screen.dart';
import 'package:pictora/router/router.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/core/utils/constants/enums.dart';

import '../../../data/model/user_model.dart';
import '../../../core/utils/constants/app_assets.dart';
import '../../../core/utils/constants/colors.dart';

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
  @override
  void initState() {
    super.initState();
    postBloc.add(GetLikedByUserEvent(postId: widget.postId));
    _scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      final state = postBloc.state;
      if (state.hasMoreLikedByUser && !state.isLoadMoreLikedByUser) {
        postBloc.add(LoadMoreLikedByUserEvent(
          body: {"skip": state.likedByUserData?.length ?? 0, "take": 20},
          postId: widget.postId,
        ));
      }
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          "Likes",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildUsersList(),
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
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: primaryColor,
      onRefresh: () async {
        postBloc.add(GetLikedByUserEvent(postId: widget.postId));
      },
      child: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) => previous.likeByUserApiStatus != current.likeByUserApiStatus,
        builder: (context, state) {
          if (state.likeByUserApiStatus == ApiStatus.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if ((state.likedByUserData ?? []).isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(vertical: 8),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.likedByUserData?.length,
            itemBuilder: (context, index) {
              final User? user = state.likedByUserData?[index];
              return InkWell(
                key: ValueKey("user_${user?.id}"),
                onTap: () {
                  if (user?.id == userId) return;
                  appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                },
                child: _buildUserTile(user),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile(User? user) {
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
              child: (user?.profile?.profilePicture ?? '').isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: user?.profile?.profilePicture ?? '',
                      cacheKey: user?.profile?.profilePicture ?? '',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return Image.asset(
                          AppAssets.profilePng,
                          height: 26,
                          width: 26,
                          fit: BoxFit.cover,
                        );
                      },
                      placeholder: (context, url) {
                        return Image.asset(
                          AppAssets.profilePng,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        );
                      },
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : _buildDefaultAvatar(user?.fullName ?? ''),
            ),
          ),

          SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.userName ?? 'guest11',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user?.fullName ?? 'guest',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          if (user?.id != userId) _buildFollowButton(user),
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
        color: primaryColor.withValues(alpha: 0.7),
      ),
      alignment: Alignment.center,
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

  Widget _buildFollowButton(User? user) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: (user?.isFollowed ?? false) ? Colors.grey[100] : primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: (user?.isFollowed ?? false) ? Border.all(color: Colors.grey[300]!, width: 1) : null,
        ),
        child: Text(
          (user?.isFollowed ?? false) ? "Following" : "Follow",
          style: TextStyle(
            color: (user?.isFollowed ?? false) ? Colors.black87 : Colors.white,
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
