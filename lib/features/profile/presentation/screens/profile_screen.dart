// Flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pictora/core/config/router.dart';
import 'package:pictora/core/config/router_name.dart';
import 'package:pictora/core/utils/services/custom_logger.dart';

// Project
import '../../../post/bloc/post_bloc.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../../../core/utils/extensions/extensions.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../../core/utils/constants/constants.dart';
import '../widgets/discover_user_view.dart';
import '../widgets/user_post_view.dart';
import '../widgets/user_profile_info.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  const ProfileScreen({super.key, this.userId, this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    logDebug(message: "widget.ssssjdhfblakshfb ==>>. ${widget.userName}");
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
      appBar: AppBar(
        titleSpacing: 10,
        title: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (previous, current) => previous.userData?.userName != current.userData?.userName,
          builder: (context, state) {
            return CustomText(
              widget.userId == null ? "@$userName" : "@${widget.userName ?? ''}",
              fontSize: 20,
              fontWeight: FontWeight.bold,
            );
          },
        ),
        actions: [
          if (widget.userId == userId)
            SvgPicture.asset(
              AppAssets.addPost,
              height: 28,
              width: 28,
            ).onTap(() {
              appRouter.go(RouterName.postAssetPicker.path);
            }),
          const SizedBox(width: 12),
          if (widget.userId == userId)
            Icon(Icons.menu, size: 28).onTap(() {
              appRouter.push(RouterName.menu.path);
            }),
          const SizedBox(width: 14),
        ],
      ),
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
  final String? userName;
  ProfileScreenDataModel({this.userId, this.userName});
}
