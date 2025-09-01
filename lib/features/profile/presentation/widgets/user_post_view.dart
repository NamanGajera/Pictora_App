// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

// Project
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../../post/bloc/post_bloc.dart';
import '../../../post/presentation/screens/post_list_screen.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import 'post_preview.dart';

class UserPostView extends StatefulWidget {
  final String? userId;
  const UserPostView({super.key, required this.userId});

  @override
  State<UserPostView> createState() => _UserPostViewState();
}

class _UserPostViewState extends State<UserPostView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: (previous, current) =>
          previous.myPostData != current.myPostData ||
          previous.otherUserPostData != current.otherUserPostData ||
          previous.getOtherUserPostApiStatus != current.getOtherUserPostApiStatus ||
          previous.getMyPostApiStatus != current.getMyPostApiStatus,
      builder: (context, state) {
        if (state.getMyPostApiStatus == ApiStatus.loading || state.getOtherUserPostApiStatus == ApiStatus.loading) {
          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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

        final postData = excludeArchivedPosts(widget.userId == null ? state.myPostData : state.otherUserPostData);

        if (postData.isEmpty == true) {
          return Column(
            children: [
              const SizedBox(height: 180),
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
              InkWell(
                onTap: () {
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
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(1),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
          ),
          itemCount: postData.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              key: ValueKey(postData[index].id),
              onTap: () {
                appRouter.push(
                  RouterName.postLists.path,
                  extra: PostListScreenDataModel(
                    postListNavigation: widget.userId == null ? PostListNavigation.myProfile : PostListNavigation.otherProfile,
                    index: index,
                  ),
                );
              },
              child: PostPreview(post: postData[index]),
            );
          },
        );
      },
    );
  }
}
