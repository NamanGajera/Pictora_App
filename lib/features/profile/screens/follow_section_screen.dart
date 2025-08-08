import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/profile/bloc/follow_section_bloc/follow_section_bloc.dart';
import 'package:pictora/utils/extensions/widget_extension.dart';

import '../../../model/user_model.dart';
import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../../../utils/Constants/enums.dart';
import '../../../utils/constants/app_assets.dart';
import '../../../utils/constants/bloc_instances.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/constants.dart';
import 'profile_screen.dart';

class FollowSectionScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final int tabIndex;
  const FollowSectionScreen({super.key, required this.userId, this.tabIndex = 0, required this.userName});

  @override
  State<FollowSectionScreen> createState() => _FollowSectionScreenState();
}

class _FollowSectionScreenState extends State<FollowSectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    followSectionBloc.add(GetFollowersEvent(
      userId: widget.userId,
    ));
    followSectionBloc.add(GetFollowingEvent(
      userId: widget.userId,
    ));

    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          widget.userName,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        initialIndex: widget.tabIndex,
        child: Column(
          children: [
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              automaticIndicatorColorAdjustment: true,
              indicator: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "Followers"),
                Tab(text: "Following"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFollowerUsersList(),
                  _buildFollowingUsersList(),
                ],
              ),
            ),
          ],
        ),
      ).withPadding(const EdgeInsets.symmetric(horizontal: 6)),
    );
  }

  Widget _buildFollowerUsersList() {
    return BlocBuilder<FollowSectionBloc, FollowSectionState>(
      buildWhen: (previous, current) => previous.getFollowersApiStatus != current.getFollowersApiStatus,
      builder: (context, state) {
        if (state.getFollowersApiStatus == ApiStatus.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if ((state.followers ?? []).isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: state.followers?.length,
          itemBuilder: (context, index) {
            final User? user = state.followers?[index];
            return InkWell(
                onTap: () {
                  appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                },
                child: _buildUserTile(user));
          },
        );
      },
    );
  }

  Widget _buildFollowingUsersList() {
    return BlocBuilder<FollowSectionBloc, FollowSectionState>(
      buildWhen: (previous, current) => previous.getFollowingApiStatus != current.getFollowingApiStatus,
      builder: (context, state) {
        if (state.getFollowingApiStatus == ApiStatus.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if ((state.following ?? []).isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: state.following?.length,
          itemBuilder: (context, index) {
            final User? user = state.following?[index];
            return InkWell(
                onTap: () {
                  appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                },
                child: _buildUserTile(user));
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "No Data Found!",
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
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

class FollowSectionScreenDataModel {
  final String userId;
  final String userName;
  final int tabIndex;
  const FollowSectionScreenDataModel({required this.userName, required this.userId, this.tabIndex = 0});
}
