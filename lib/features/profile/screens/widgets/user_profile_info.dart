import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/extensions/build_context_extension.dart';
import 'package:pictora/core/utils/extensions/widget_extension.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/constants/bloc_instances.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/constants/enums.dart';
import '../../../../core/utils/helper/helper_function.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../../data/model/user_model.dart';
import '../../../../router/router.dart';
import '../../../../router/router_name.dart';
import '../../bloc/follow_section_bloc/follow_section_bloc.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../follow_section_screen.dart';

class UserProfileInfo extends StatefulWidget {
  final String? userId;
  const UserProfileInfo({super.key, required this.userId});

  @override
  State<UserProfileInfo> createState() => _UserProfileInfoState();
}

class _UserProfileInfoState extends State<UserProfileInfo> {
  @override
  Widget build(BuildContext context) {
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
        userId: userData?.id ?? '',
      ),
    ).withAutomaticKeepAlive();
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedCount(count),
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
                appRouter.push(RouterName.profileEdit.path);
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
