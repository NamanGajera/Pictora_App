import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/post/models/post_data.dart';
import 'package:pictora/features/post/screens/post_list_screen.dart';
import 'package:pictora/features/profile/bloc/profile_bloc/profile_bloc.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/utils/constants/bloc_instances.dart';
import 'package:pictora/utils/constants/colors.dart';
import 'package:pictora/utils/constants/constants.dart';
import 'package:pictora/utils/extensions/widget_extension.dart';

import '../../../model/user_model.dart';
import '../../../router/router.dart';
import 'follow_section_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xffF8FAF9),
      body: Column(
        children: [
          _buildProfileInfo(),
          Expanded(
            child: _buildPostsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) {
        // Only rebuild when user data actually changes
        if (widget.userId == null) {
          return previous.userData != current.userData;
        } else {
          return previous.otherUserData != current.otherUserData;
        }
      },
      builder: (context, state) {
        User? userData = widget.userId == null ? state.userData : state.otherUserData;
        return Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildProfilePicture(userData),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Posts', userData?.counts?.postCount ?? 0),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            InkWell(
                              onTap: () {
                                appRouter.push(
                                  RouterName.followSection.path,
                                  extra: FollowSectionScreenDataModel(
                                    userId: userData?.id ?? '',
                                    userName: userData?.userName ?? '',
                                    tabIndex: 0,
                                  ),
                                );
                              },
                              child: _buildStatItem('Followers', userData?.counts?.followerCount ?? 0),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            InkWell(
                              onTap: () {
                                appRouter.push(
                                  RouterName.followSection.path,
                                  extra: FollowSectionScreenDataModel(
                                    userId: userData?.id ?? '',
                                    userName: userData?.userName ?? '',
                                    tabIndex: 1,
                                  ),
                                );
                              },
                              child: _buildStatItem('Following', userData?.counts?.followingCount ?? 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userData?.fullName ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1F2937),
                    ),
                  ),
                  if ((userData?.profile?.bio ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      userData!.profile!.bio!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xff6B7280),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildActionButtons(userData?.id ?? ''),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePicture(User? userData) {
    return Container(
      key: ValueKey('profile_picture_${userData?.id}'),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 42,
        backgroundColor: const Color(0xffF5F5F5),
        child: (userData?.profile?.profilePicture ?? '').isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  cacheKey: 'profile_pic_${userData?.id}',
                  imageUrl: userData!.profile!.profilePicture!,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9CA3AF)),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xffF3F4F6),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xff9CA3AF),
                      size: 32,
                    ),
                  ),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                ),
              )
            : const Icon(
                Icons.person_rounded,
                size: 40,
                color: Color(0xff9CA3AF),
              ),
      ),
    ).withAutomaticKeepAlive();
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatNumber(count),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xff1F2937),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff6B7280),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String profileUserId) {
    if (profileUserId == userId) {
      return Row(
        children: [
          Expanded(
            child: _buildButton(
              'Edit Profile',
              backgroundColor: const Color(0xffF3F4F6),
              textColor: const Color(0xff374151),
              onTap: () {
                // Handle edit profile
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildButton(
              'Share Profile',
              backgroundColor: const Color(0xffF3F4F6),
              textColor: const Color(0xff374151),
              onTap: () {},
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildButton(
              'Following',
              backgroundColor: primaryColor,
              textColor: Colors.white,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildButton(
              'Message',
              backgroundColor: const Color(0xffF3F4F6),
              textColor: const Color(0xff374151),
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: backgroundColor == primaryColor
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        final postData = widget.userId == null ? state.myPostData : state.otherUserPostData;

        if (postData?.isEmpty == true || postData == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Color(0xff9CA3AF),
                ),
                SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: postData.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                appRouter.push(
                  RouterName.postLists.path,
                  extra: PostListScreenDataModel(postData: postData, index: index),
                );
              },
              child: _buildPostPreview(postData[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildPostPreview(PostData? post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: post?.mediaData?[0].mediaUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[100],
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9CA3AF)),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xffF3F4F6),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xff9CA3AF),
                size: 32,
              ),
            ),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if ((post?.mediaData?.length ?? 0) > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  color: Colors.white,
                  size: 16,
                ),
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

  @override
  bool get wantKeepAlive => true;
}

class ProfileScreenDataModel {
  final String? userId;
  ProfileScreenDataModel({this.userId});
}
