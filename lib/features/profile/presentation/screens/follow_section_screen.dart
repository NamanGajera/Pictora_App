import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/profile/bloc/follow_section_bloc/follow_section_bloc.dart';
import 'package:pictora/core/utils/extensions/extensions.dart';
import 'package:pictora/core/utils/widgets/custom_widget.dart';

import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
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
  @override
  void initState() {
    super.initState();
    followSectionBloc.add(GetFollowersEvent(
      userId: widget.userId,
    ));
    followSectionBloc.add(GetFollowingEvent(
      userId: widget.userId,
    ));
    followSectionBloc.add(GetFollowRequestEvent());
    followSectionBloc.add(GetDiscoverUsersEvent());

    _selectedIndex = widget.tabIndex;

    _followerScrollController.addListener(followerScrollListener);
    _followingScrollController.addListener(followingScrollListener);
    _discoverScrollController.addListener(discoverScrollListener);
  }

  final ScrollController _followerScrollController = ScrollController();
  final ScrollController _followingScrollController = ScrollController();
  final ScrollController _discoverScrollController = ScrollController();

  void followerScrollListener() {
    if (_followerScrollController.position.pixels > _followerScrollController.position.maxScrollExtent - 150) {
      final state = followSectionBloc.state;
      if (state.hasMoreFollowers) {
        followSectionBloc.add(LoadMoreFollowersEvent(body: {
          "userId": widget.userId,
          "skip": state.followers?.length ?? 0,
          "take": 15,
        }));
      }
    }
  }

  void followingScrollListener() {
    if (_followingScrollController.position.pixels > _followingScrollController.position.maxScrollExtent - 150) {
      final state = followSectionBloc.state;
      if (state.hasMoreFollowing) {
        followSectionBloc.add(LoadMoreFollowingEvent(body: {
          "userId": widget.userId,
          "skip": state.following?.length ?? 0,
          "take": 15,
        }));
      }
    }
  }

  void discoverScrollListener() {
    if (_discoverScrollController.position.pixels > _discoverScrollController.position.maxScrollExtent - 150) {
      final state = followSectionBloc.state;
      if (state.hasMoreDiscover) {
        followSectionBloc.add(LoadMoreDiscoverUserEvent(body: {
          "skip": state.discoverUsers?.length ?? 0,
          "take": 15,
        }));
      }
    }
  }

  int _selectedIndex = 0;
  final List<String> _tabs = [
    "Followers",
    "Following",
    "Requests",
    "Discover",
  ];

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
      body: Column(
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return _buildTabButton(_tabs[index], index);
              }),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildFollowerUsersList(),
                _buildFollowingUsersList(),
                _buildFollowRequestList(),
                _buildDiscoverUsersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildFollowerUsersList() {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: primaryColor,
      onRefresh: () async {
        followSectionBloc.add(GetFollowersEvent(
          userId: widget.userId,
        ));
      },
      child: BlocBuilder<FollowSectionBloc, FollowSectionState>(
        buildWhen: (previous, current) =>
            previous.getFollowersApiStatus != current.getFollowersApiStatus ||
            previous.followers != current.followers ||
            previous.isLoadMoreFollowers != current.isLoadMoreFollowers,
        builder: (context, state) {
          if (state.getFollowersApiStatus == ApiStatus.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if ((state.followers ?? []).isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _followerScrollController,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.followers?.length ?? 0,
                  itemBuilder: (context, index) {
                    final User? user = state.followers?[index];
                    return InkWell(
                      onTap: () {
                        appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                      },
                      child: _buildUserTile(
                        user,
                        FollowSectionTab.follower,
                      ),
                    );
                  },
                ),
              ),
              if (state.isLoadMoreFollowing)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFollowingUsersList() {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: primaryColor,
      onRefresh: () async {
        followSectionBloc.add(GetFollowingEvent(
          userId: widget.userId,
        ));
      },
      child: BlocBuilder<FollowSectionBloc, FollowSectionState>(
        buildWhen: (previous, current) =>
            previous.getFollowingApiStatus != current.getFollowingApiStatus ||
            previous.following != current.following ||
            previous.isLoadMoreFollowing != current.isLoadMoreFollowing,
        builder: (context, state) {
          if (state.getFollowingApiStatus == ApiStatus.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if ((state.following ?? []).isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _followingScrollController,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.following?.length ?? 0,
                  itemBuilder: (context, index) {
                    final User? user = state.following?[index];
                    return InkWell(
                      onTap: () {
                        appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                      },
                      child: _buildUserTile(
                        user,
                        FollowSectionTab.following,
                      ),
                    );
                  },
                ),
              ),
              if (state.isLoadMoreFollowing)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFollowRequestList() {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: primaryColor,
      onRefresh: () async {
        followSectionBloc.add(GetFollowRequestEvent());
      },
      child: BlocBuilder<FollowSectionBloc, FollowSectionState>(
        buildWhen: (previous, current) =>
            previous.getFollowRequestApiStatus != current.getFollowRequestApiStatus || previous.followRequests != current.followRequests,
        builder: (context, state) {
          if (state.getFollowRequestApiStatus == ApiStatus.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if ((state.followRequests ?? []).isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: state.followRequests?.length ?? 0,
            itemBuilder: (context, index) {
              final User? user = state.followRequests?[index].requester;
              return InkWell(
                onTap: () {
                  appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                },
                child: _buildUserTile(
                  user,
                  FollowSectionTab.request,
                  state.followRequests?[index].id,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDiscoverUsersList() {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: primaryColor,
      onRefresh: () async {
        followSectionBloc.add(GetDiscoverUsersEvent());
      },
      child: BlocBuilder<FollowSectionBloc, FollowSectionState>(
        buildWhen: (previous, current) =>
            previous.getDiscoverUsersApiStatus != current.getDiscoverUsersApiStatus ||
            previous.discoverUsers != current.discoverUsers ||
            previous.isLoadMoreDiscover != current.isLoadMoreDiscover,
        builder: (context, state) {
          if (state.getDiscoverUsersApiStatus == ApiStatus.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if ((state.discoverUsers ?? []).isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _discoverScrollController,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.discoverUsers?.length ?? 0,
                  itemBuilder: (context, index) {
                    final User? user = state.discoverUsers?[index];
                    return InkWell(
                      onTap: () {
                        appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: user?.id ?? ''));
                      },
                      child: _buildUserTile(user, FollowSectionTab.discover),
                    );
                  },
                ),
              ),
              if (state.isLoadMoreDiscover)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
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

  Widget _buildUserTile(User? user, FollowSectionTab tab, [String? requestId]) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          RoundProfileAvatar(
            imageUrl: user?.profile?.profilePicture ?? '',
            radius: 24,
            userId: user?.id ?? '',
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

          if (user?.id != userId) ...[
            if (tab == FollowSectionTab.request) ...[
              Row(
                children: [
                  CustomButton(
                    width: context.screenWidth * 0.19,
                    height: 38,
                    text: "Accept",
                    fontSize: 14,
                    onTap: () {
                      followSectionBloc.add(ManageFollowRequestEvent(
                        userId: user?.id ?? '',
                        requestId: requestId ?? '',
                        isAccept: true,
                      ));
                    },
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    width: context.screenWidth * 0.19,
                    height: 38,
                    text: "Reject",
                    fontSize: 14,
                    onTap: () {},
                  ),
                ],
              )
            ] else if (user?.followRequestStatus == FollowRequest.pending.name) ...[
              CustomButton(
                width: context.screenWidth * 0.24,
                height: 38,
                text: "Requested",
                fontSize: 14,
                onTap: () {
                  followSectionBloc.add(ToggleFollowUserEvent(
                    userId: user?.id ?? '',
                    isFollowing: false,
                    isPrivate: user?.profile?.isPrivate ?? false,
                  ));
                },
              ),
            ] else if (user?.isFollowed == true) ...[
              CustomButton(
                width: context.screenWidth * 0.24,
                height: 38,
                text: "Following",
                textColor: Colors.grey.shade600,
                backgroundColor: Colors.transparent,
                borderColor: Colors.grey,
                fontSize: 14,
                onTap: () {
                  followSectionBloc.add(ToggleFollowUserEvent(
                    userId: user?.id ?? '',
                    isFollowing: false,
                  ));
                },
              ),
            ] else if (user?.showFollowBack == true) ...[
              CustomButton(
                width: context.screenWidth * 0.24,
                height: 38,
                text: "Follow Back",
                textColor: Colors.white,
                backgroundColor: primaryColor,
                borderColor: primaryColor,
                fontSize: 14,
                onTap: () {
                  followSectionBloc.add(ToggleFollowUserEvent(
                    userId: user?.id ?? '',
                    isFollowing: true,
                    isPrivate: user?.profile?.isPrivate ?? false,
                  ));
                },
              ),
            ] else ...[
              CustomButton(
                width: context.screenWidth * 0.24,
                height: 38,
                text: "Follow",
                textColor: Colors.white,
                backgroundColor: primaryColor,
                borderColor: primaryColor,
                fontSize: 14,
                onTap: () {
                  followSectionBloc.add(ToggleFollowUserEvent(
                    userId: user?.id ?? '',
                    isFollowing: true,
                    isPrivate: user?.profile?.isPrivate ?? false,
                  ));
                },
              ),
            ]
          ]
        ],
      ),
    );
  }
}

class FollowSectionScreenDataModel {
  final String userId;
  final String userName;
  final int tabIndex;
  const FollowSectionScreenDataModel({
    required this.userName,
    required this.userId,
    this.tabIndex = 0,
  });
}
