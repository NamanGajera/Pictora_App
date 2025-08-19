import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/post/models/post_data.dart';
import 'package:pictora/features/post/screens/post_list_screen.dart';
import 'package:pictora/features/profile/bloc/profile_bloc/profile_bloc.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/constants/colors.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/core/utils/extensions/build_context_extension.dart';
import 'package:pictora/core/utils/extensions/string_extensions.dart';
import 'package:pictora/core/utils/extensions/widget_extension.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/model/user_model.dart';
import '../../../router/router.dart';
import '../../../core/utils/constants/enums.dart';
import '../../../core/utils/widgets/custom_widget.dart';
import '../bloc/follow_section_bloc/follow_section_bloc.dart';
import 'follow_section_screen.dart';
import 'widgets/discover_user_card.dart';

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
        "take": 24,
        "userId": userId,
      }));
    } else {
      postBloc.add(GetOtherUserPostsEvent(body: {
        "skip": 0,
        "take": 24,
        "userId": widget.userId,
      }));
    }

    _scrollController.addListener(_scrollListener);
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final currentState = postBloc.state;
    if (widget.userId == null) {
      if (currentState.hasMoreMyPost) {
        postBloc.add(LoadMoreMyPostEvent(body: {
          "skip": currentState.myPostData?.length,
          "take": 15,
          "userId": userId,
        }));
      }
    } else {
      if (currentState.hasMoreOtherUserPost) {
        postBloc.add(LoadMoreOtherUserPostEvent(body: {
          "skip": currentState.otherUserPostData?.length,
          "take": 15,
          "userId": widget.userId,
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xffF8FAF9),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: primaryColor,
        onRefresh: () async {
          profileBloc.add(GetUserDataEvent(userId: widget.userId));
          if (widget.userId == null) {
            postBloc.add(GetMyPostEvent(body: {
              "skip": 0,
              "take": 24,
              "userId": userId,
            }));
          } else {
            postBloc.add(GetOtherUserPostsEvent(body: {
              "skip": 0,
              "take": 24,
              "userId": widget.userId,
            }));
          }
        },
        child: Column(
          children: [
            _buildProfileInfo(),
            BlocBuilder<FollowSectionBloc, FollowSectionState>(
              buildWhen: (previous, current) =>
                  previous.showDiscoverUserOnProfile != current.showDiscoverUserOnProfile || previous.discoverUsers != current.discoverUsers,
              builder: (context, state) {
                final users = state.discoverUsers ?? [];

                if (users.isNotEmpty && state.showDiscoverUserOnProfile) {
                  return SizedBox(
                    height: 242,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(top: 12, bottom: 12, left: 10),
                      itemCount: ((users.take(5)).length) + (users.length > 5 ? 1 : 0),
                      itemBuilder: (context, index) {
                        List<String> randomProfiles = [];
                        if (index == 5 && users.length > 2) {
                          List<User> availableUsers = List.from(users);

                          availableUsers.shuffle();

                          randomProfiles = availableUsers.take(2).map((user) => user.profile?.profilePicture ?? '').toList();
                        }

                        final user = users[index];
                        return DiscoverUserCard(
                          key: ValueKey("discover_${user.id}"),
                          user: user,
                          isLast: index == 5,
                          lastTwoUserProfile: randomProfiles,
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: _buildPostsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) {
        if (widget.userId == null) {
          return previous.userData != current.userData || previous.getUserDataApiStatus != current.getUserDataApiStatus;
        } else {
          return previous.otherUserData != current.otherUserData || previous.getUserDataApiStatus != current.getUserDataApiStatus;
        }
      },
      builder: (context, state) {
        if (state.getUserDataApiStatus == ApiStatus.loading) {
          return const ShimmerProfileInfo();
        }
        User? userData = widget.userId == null ? state.userData : state.otherUserData;
        return Container(
          color: Colors.white,
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
                        Expanded(child: _buildStatItem('Posts', userData?.counts?.postCount ?? 0)),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        Expanded(
                          child: InkWell(
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
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        Expanded(
                          child: InkWell(
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
              _buildActionButtons(userData),
            ],
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
      child: RoundProfileAvatar(
        imageUrl: userData?.profile?.profilePicture ?? '',
        radius: 42,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons(User? userData) {
    if (userData?.id == userId) {
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
          BlocBuilder<FollowSectionBloc, FollowSectionState>(
            builder: (context, state) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xffF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: state.getDiscoverUsersApiStatus == ApiStatus.loading && (state.discoverUsers ?? []).isEmpty
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.person_add_alt_1,
                          size: 24,
                          color: Color(0xff374151),
                        ),
                ),
              ).onTap(() {
                followSectionBloc.add(ShowDiscoverUserOnProfileEvent(showUser: !state.showDiscoverUserOnProfile));
              });
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: BlocBuilder<FollowSectionBloc, FollowSectionState>(
              builder: (context, state) {
                if (userData?.followRequestStatus == FollowRequest.pending.name) {
                  return CustomButton(
                    width: context.screenWidth * 0.24,
                    height: 38,
                    text: "Requested",
                    fontSize: 14,
                    onTap: () {
                      followSectionBloc.add(ToggleFollowUserEvent(
                        userId: userData?.id ?? '',
                        isFollowing: false,
                        isPrivate: userData?.profile?.isPrivate ?? false,
                      ));
                    },
                  );
                } else if (userData?.isFollowed == true) {
                  return CustomButton(
                    width: context.screenWidth * 0.24,
                    height: 38,
                    text: "Following",
                    textColor: Colors.grey.shade600,
                    backgroundColor: Colors.transparent,
                    borderColor: Colors.grey,
                    fontSize: 14,
                    onTap: () {
                      followSectionBloc.add(ToggleFollowUserEvent(
                        userId: userData?.id ?? '',
                        isFollowing: false,
                      ));
                    },
                  );
                } else if (userData?.showFollowBack == true) {
                  return CustomButton(
                    width: context.screenWidth * 0.24,
                    height: 38,
                    text: "Follow Back",
                    textColor: Colors.white,
                    backgroundColor: primaryColor,
                    borderColor: primaryColor,
                    fontSize: 14,
                    onTap: () {
                      followSectionBloc.add(ToggleFollowUserEvent(
                        userId: userData?.id ?? '',
                        isFollowing: true,
                        isPrivate: userData?.profile?.isPrivate ?? false,
                      ));
                    },
                  );
                } else {
                  return CustomButton(
                    width: context.screenWidth * 0.24,
                    height: 38,
                    text: "Follow",
                    textColor: Colors.white,
                    backgroundColor: primaryColor,
                    borderColor: primaryColor,
                    fontSize: 14,
                    onTap: () {
                      followSectionBloc.add(ToggleFollowUserEvent(
                        userId: userData?.id ?? '',
                        isFollowing: true,
                        isPrivate: userData?.profile?.isPrivate ?? false,
                      ));
                    },
                  );
                }
              },
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
        if (state.getMyPostApiStatus == ApiStatus.loading || state.getOtherUserPostApiStatus == ApiStatus.loading) {
          return GridView.builder(
            padding: const EdgeInsets.all(1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: 21,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.white,
                ),
              );
            },
          );
        }

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
          controller: _scrollController,
          padding: const EdgeInsets.all(1),
          physics: const AlwaysScrollableScrollPhysics(),
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
                  extra: PostListScreenDataModel(
                    postListNavigation: widget.userId == null ? PostListNavigation.myProfile : PostListNavigation.otherProfile,
                    index: index,
                  ),
                );
              },
              child: _buildPostPreview(postData[index]).withAutomaticKeepAlive(),
            );
          },
        );
      },
    );
  }

  Widget _buildPostPreview(PostData? post) {
    String? firstMediaUrl = post?.mediaData?[0].mediaUrl;
    String? thumbnailUrl = post?.mediaData?[0].thumbnail;

    String displayUrl = (firstMediaUrl != null && firstMediaUrl.isVideoUrl) ? (thumbnailUrl ?? firstMediaUrl) : (firstMediaUrl ?? '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: displayUrl,
            cacheKey: displayUrl,
            key: ValueKey(displayUrl),
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

  @override
  bool get wantKeepAlive => true;
}

class ProfileScreenDataModel {
  final String? userId;
  ProfileScreenDataModel({this.userId});
}

class ShimmerProfileInfo extends StatelessWidget {
  const ShimmerProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile picture shimmer
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 24),
                // Stats shimmer
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShimmerStatItem(),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[200],
                      ),
                      _buildShimmerStatItem(),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[200],
                      ),
                      _buildShimmerStatItem(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Name shimmer
            Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Bio shimmer (3 lines)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 250,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Action buttons shimmer
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerStatItem() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
