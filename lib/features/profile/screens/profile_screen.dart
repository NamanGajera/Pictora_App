import 'package:flutter/material.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/profile/bloc/profile_bloc/profile_bloc.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/constants/colors.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'widgets/discover_user_view.dart';
import 'widgets/user_post_view.dart';
import 'widgets/user_profile_info.dart';

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
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              UserProfileInfo(userId: widget.userId),
              DiscoverUserView(),
              UserPostView(
                userId: widget.userId,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ProfileScreenDataModel {
  final String? userId;
  ProfileScreenDataModel({this.userId});
}
