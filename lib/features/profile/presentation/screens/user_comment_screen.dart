// Flutter
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/features/post/post.dart';
import '../../../../core/config/router.dart';
import '../../../../core/utils/widgets/custom_widget.dart';

class UserCommentScreen extends StatefulWidget {
  const UserCommentScreen({super.key});

  @override
  State<UserCommentScreen> createState() => _UserCommentScreenState();
}

class _UserCommentScreenState extends State<UserCommentScreen> {
  @override
  void initState() {
    super.initState();
    postBloc.add(GetUserCommentsEvent());
    _scrollController.addListener(_scrollListener);
  }

  final postBody = {"skip": 0, "take": 24};
  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final currentState = postBloc.state;
    if (currentState.hasMoreUserComments) {
      postBody["skip"] = (currentState.userCommentsData?.length ?? 0);
      postBloc.add(LoadMoreUserCommentsEvent(body: postBody));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 10,
        title: const CustomText(
          'Comments',
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontSize: 18,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => appRouter.pop(),
        ),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        buildWhen: (previous, current) =>
            previous.getUserCommentApiStatus != current.getUserCommentApiStatus || previous.userCommentsData != current.userCommentsData,
        builder: (context, state) {
          if (state.getUserCommentApiStatus == ApiStatus.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final commentData = (state.userCommentsData ?? []);
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemCount: (commentData.length) + (state.isLoadMoreUserComments && state.hasMoreUserComments ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == commentData.length) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final comment = commentData[index];
              final commentPost = commentData[index].post;
              return InkWell(
                key: ValueKey(comment.id),
                onTap: () {
                  showModalBottomSheet(
                    context: bottomBarContext ?? context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    transitionAnimationController: AnimationController(
                      vsync: Navigator.of(context),
                      duration: const Duration(milliseconds: 300),
                    ),
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: CommentScreen(
                          postId: "${commentPost?.id}",
                          postUserId: commentPost?.userId ?? '',
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoundProfileAvatar(
                        radius: 20,
                        userId: commentPost?.userData?.id ?? '',
                        imageUrl: commentPost?.userData?.profile?.profilePicture,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                text: commentPost?.userData?.userName ?? '',
                                children: [
                                  TextSpan(
                                    text: " ${commentPost?.caption ?? ''}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                RoundProfileAvatar(
                                  radius: 15,
                                  userId: userId ?? '',
                                  imageUrl: userProfilePic ?? '',
                                ),
                                const SizedBox(width: 8),
                                CustomText(
                                  comment.comment ?? '',
                                  fontSize: 12,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      CachedNetworkImage(
                        imageUrl: commentPost?.mediaData?[0].mediaUrl ?? '',
                        cacheKey: commentPost?.mediaData?[0].id,
                        width: 45,
                        height: 55,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xff9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xffF3F4F6),
                          height: double.infinity,
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
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
