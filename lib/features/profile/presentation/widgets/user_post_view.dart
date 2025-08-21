import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/extensions/extensions.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
import '../../../post/bloc/post_bloc.dart';
import '../../../post/models/post_data.dart';
import '../../../post/presentation/screens/post_list_screen.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';

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

        final postData = widget.userId == null ? state.myPostData : state.otherUserPostData;

        if (postData?.isEmpty == true || postData == null) {
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

class PostPreview extends StatefulWidget {
  final PostData? post;
  const PostPreview({
    super.key,
    required this.post,
  });

  @override
  State<PostPreview> createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    String? firstMediaUrl = widget.post?.mediaData?[0].mediaUrl;
    String? thumbnailUrl = widget.post?.mediaData?[0].thumbnail;

    String displayUrl = (firstMediaUrl != null && firstMediaUrl.isVideoUrl) ? (thumbnailUrl ?? firstMediaUrl) : (firstMediaUrl ?? '');
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: displayUrl,
          cacheKey: widget.post?.mediaData?[0].id,
          key: ValueKey(widget.post?.mediaData?[0].id),
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
        if ((widget.post?.mediaData?.length ?? 0) > 1)
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
