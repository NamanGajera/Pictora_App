import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/post/models/post_comment_data_model.dart';
import 'package:pictora/core/utils/constants/bloc_instances.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/core/utils/extensions/build_context_extension.dart';
import '../../../router/router.dart';
import '../../../router/router_name.dart';
import '../../../core/utils/constants/app_assets.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/constants/enums.dart';
import '../../../core/utils/constants/overlay_ids.dart';
import '../../../core/utils/helper/date_formatter.dart';
import '../../../core/utils/helper/helper_function.dart';
import '../../../core/utils/widgets/custom_overlay.dart';
import '../../../core/utils/widgets/custom_widget.dart';
import '../../profile/screens/profile_screen.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String postUserId;
  const CommentScreen({
    super.key,
    required this.postId,
    required this.postUserId,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<GlobalKey> commentKeys = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    postBloc.add(GetPostCommentDataEvent(postId: widget.postId));
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _commentController.dispose();
    selectedCommentId.value = null;
    postBloc.add(ClearRepliesData());
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    postBloc.add(CreateCommentEvent(
      comment: _commentController.text.trim(),
      postId: widget.postId,
      userId: userId,
      commentParentId: selectedCommentId.value,
    ));

    selectedCommentId.value = null;
    _commentController.clear();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 50) {
      final currentState = postBloc.state;

      if (currentState.hasMorePostComments) {
        postBloc.add(LoadMorePostCommentDataEvent(body: {
          "postId": widget.postId,
          "skip": currentState.commentDataList?.length ?? 0,
          "take": 15,
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Comments'),
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state.getPostCommentListApiStatus == ApiStatus.loading) {
              return Container(
                alignment: Alignment.center,
                height: context.screenHeight * 0.93,
                child: const CircularProgressIndicator(),
              );
            } else if (state.getPostCommentListApiStatus == ApiStatus.failure) {
              return const Center(child: Text('Failed to load comments'));
            } else {
              commentKeys = List.generate((state.commentDataList ?? []).length, (_) => GlobalKey());
              return Column(
                children: [
                  Expanded(
                    child: (state.commentDataList ?? []).isEmpty
                        ? const Center(
                            child: Text(
                              'No comments yet.\nBe the first to comment!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            backgroundColor: Colors.white,
                            color: primaryColor,
                            onRefresh: () async {
                              postBloc.add(GetPostCommentDataEvent(postId: widget.postId));
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: (state.commentDataList ?? []).length,
                              itemBuilder: (context, index) {
                                CommentData? comment = state.commentDataList?[index];
                                return GestureDetector(
                                  onDoubleTap: () {
                                    if (comment?.id == null) return;
                                    postBloc.add(ToggleCommentLikeEvent(
                                      commentId: comment?.id ?? '',
                                      isLike: !(comment?.isLiked ?? false),
                                    ));
                                  },
                                  child: CommentItem(
                                    key: commentKeys[index],
                                    globalKey: commentKeys[index],
                                    comment: comment,
                                    postId: widget.postId,
                                    postUserId: widget.postUserId,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  _buildCommentInput(context),
                ],
              );
            }
          },
        ));
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: Row(
          children: [
            RoundProfileAvatar(
              imageUrl: userProfilePic,
              radius: 23,
              userId: userId ?? '',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: selectedCommentId,
                builder: (context, value, child) {
                  return TextField(
                    controller: _commentController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Add a ${selectedCommentId.value != null ? 'reply' : 'comment'}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _commentController.text.trim().isEmpty ? null : _postComment,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.only(left: 11, right: 8, top: 11, bottom: 11),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _commentController.text.trim().isEmpty ? primaryColor.withValues(alpha: 0.6) : Theme.of(context).primaryColor,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ValueNotifier<String?> selectedCommentId = ValueNotifier(null);

class CommentItem extends StatefulWidget {
  final CommentData? comment;
  final String postId;
  final GlobalKey? globalKey;
  final String postUserId;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    required this.postUserId,
    this.globalKey,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  List<GlobalKey> childCommentKeys = [];

  void _highlightCommentWithBlurBG(BuildContext context, Widget child, Offset position) {
    final screenHeight = MediaQuery.of(context).size.height;
    final commentHeight = 80.0;
    final deleteRowHeight = 50.0;
    final padding = 5.0;

    final hasEnoughSpaceBelow = (position.dy + commentHeight + deleteRowHeight + padding) < screenHeight;

    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );

    final slideAnimation = Tween<double>(
      begin: hasEnoughSpaceBelow ? 0.0 : 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    ));

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    animationController.forward();

    OverlayManager().show(
      context: context,
      overlayId: OverlayIds.blurBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                animationController.reverse().then((_) {
                  OverlayManager().hide(OverlayIds.blurBg);
                  animationController.dispose();
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              top: !hasEnoughSpaceBelow ? position.dy - 75 : position.dy,
              left: position.dx - 15,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, !hasEnoughSpaceBelow ? slideAnimation.value : 0),
                    child: Opacity(
                      opacity: opacityAnimation.value,
                      child: child,
                    ),
                  );
                },
              ),
            ),
            if (widget.comment?.id != null && widget.comment?.userId == userId)
              Positioned(
                top: position.dy + (!hasEnoughSpaceBelow ? 0 : 75),
                left: position.dx - 5,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, !hasEnoughSpaceBelow ? slideAnimation.value : 0),
                      child: Opacity(
                        opacity: opacityAnimation.value,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      OverlayManager().hide(OverlayIds.blurBg);
                                      animationController.dispose();
                                      postBloc.add(
                                        DeleteCommentEvent(
                                          postId: widget.postId,
                                          commentId: widget.comment?.id ?? '',
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        CustomText(
                                          'Delete',
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onLongPress: () {
        HapticFeedback.vibrate();
        final renderBox = widget.globalKey?.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);

        _highlightCommentWithBlurBG(
          context,
          SizedBox(
            width: context.screenWidth,
            child: HighlightedComment(
              comment: widget.comment,
              postId: widget.postId,
            ),
          ),
          position,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () {
                    if (widget.comment?.user?.id == userId) return;
                    appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: widget.comment?.user?.id ?? ''));
                  },
                  child: RoundProfileAvatar(
                    imageUrl: widget.comment?.user?.profile?.profilePicture ?? '',
                    radius: 18,
                    userId: widget.comment?.user?.id ?? '',
                  ),
                ),
                if (widget.comment?.apiStatus == PostCommentApiStatus.posting)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                      ),
                    ),
                  ),
                if (widget.comment?.apiStatus == PostCommentApiStatus.failure)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.comment?.user?.id == userId) return;
                          appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: widget.comment?.user?.id ?? ''));
                        },
                        child: Row(
                          children: [
                            Text(
                              widget.comment?.user?.userName ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (widget.comment?.apiStatus == PostCommentApiStatus.posting) ...[
                              const CustomText(
                                'Posting...',
                                fontSize: 12,
                                color: Colors.amber,
                                fontStyle: FontStyle.italic,
                              ),
                            ],
                            if (widget.comment?.apiStatus == PostCommentApiStatus.deleting) ...[
                              const CustomText(
                                'Deleting...',
                                fontSize: 12,
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                              ),
                            ],
                            if (!([PostCommentApiStatus.posting, PostCommentApiStatus.failure, PostCommentApiStatus.deleting]
                                .contains(widget.comment?.apiStatus))) ...[
                              Text(
                                DateFormatter.getRelativeTime(widget.comment?.createdAt),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.comment?.userId == userId) const SizedBox(height: 4),
                      Text(
                        widget.comment?.comment ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (widget.comment?.apiStatus == PostCommentApiStatus.failure) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'Failed to post. ',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                postBloc.add(
                                  CreateCommentEvent(
                                    postId: widget.postId,
                                    comment: widget.comment?.comment ?? '',
                                    userId: userId,
                                  ),
                                );
                              },
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(
                        height: 2,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          selectedCommentId.value = widget.comment?.id;
                        },
                        child: CustomText(
                          'reply',
                          fontSize: 13,
                        ),
                      ),
                      if ((widget.comment?.repliesCount ?? 0) != 0) ...[
                        BlocBuilder<PostBloc, PostState>(
                          builder: (context, state) {
                            return (state.showReplies ?? {}).containsKey(widget.comment?.id)
                                ? (state.showReplies?[widget.comment?.id] == true)
                                    ? Center(
                                        child: CustomText(
                                          'Loading...',
                                          fontSize: 14,
                                        ),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListView.builder(
                                            itemCount: (widget.comment?.repliesData ?? []).length,
                                            shrinkWrap: true,
                                            padding: EdgeInsets.only(top: 10, bottom: 10),
                                            physics: NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, replyIndex) {
                                              childCommentKeys = List.generate((widget.comment?.repliesData ?? []).length, (_) => GlobalKey());
                                              final CommentData? childComment = widget.comment?.repliesData?[replyIndex];

                                              return InkWell(
                                                  splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onDoubleTap: () {
                                                    if (childComment?.id == null) return;
                                                    postBloc.add(ToggleCommentLikeEvent(
                                                      commentId: childComment?.id ?? '',
                                                      isLike: !(childComment?.isLiked ?? false),
                                                    ));
                                                  },
                                                  child: ChildCommentItem(
                                                    childComment: childComment,
                                                    postId: widget.postId,
                                                    key: childCommentKeys[replyIndex],
                                                    globalKey: childCommentKeys[replyIndex],
                                                    parentCommentId: widget.comment?.id ?? '',
                                                  ));
                                            },
                                          ),
                                          if (state.hasMoreCommentReplies)
                                            InkWell(
                                              onTap: () {
                                                postBloc.add(
                                                  LoadMoreCommentRepliesEvent(
                                                    commentId: widget.comment?.id ?? '',
                                                    skip: widget.comment?.repliesData?.length ?? 0,
                                                    take: 10,
                                                  ),
                                                );
                                              },
                                              child: CustomText(
                                                state.isLoadMoreReplies ? "Loading..." : "View more replies",
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                        ],
                                      )
                                : Column(
                                    children: [
                                      SizedBox(height: 8),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          postBloc.add(GetCommentRepliesEvent(commentId: widget.comment?.id ?? ''));
                                        },
                                        child: CustomText(
                                          'View ${formattedCount(widget.comment?.repliesCount ?? 0)} more replies',
                                          fontSize: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ]
                    ],
                  ),
                  if (widget.comment?.id != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              postBloc.add(ToggleCommentLikeEvent(
                                commentId: widget.comment?.id ?? '',
                                isLike: !(widget.comment?.isLiked ?? false),
                              ));
                            },
                            child: SvgPicture.asset(
                              (widget.comment?.isLiked ?? false) ? AppAssets.heartFill : AppAssets.heart,
                              height: 20,
                              width: 20,
                              colorFilter: ColorFilter.mode(
                                (widget.comment?.isLiked ?? false) ? Colors.red : Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          if ((widget.comment?.likeCount ?? 0) != 0)
                            CustomText(
                              formattedCount(widget.comment?.likeCount ?? 0),
                              fontSize: 12,
                            ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildCommentItem extends StatefulWidget {
  final CommentData? childComment;
  final String postId;
  final String parentCommentId;
  final GlobalKey? globalKey;
  const ChildCommentItem({
    super.key,
    required this.childComment,
    required this.globalKey,
    required this.postId,
    required this.parentCommentId,
  });

  @override
  State<ChildCommentItem> createState() => _ChildCommentItemState();
}

class _ChildCommentItemState extends State<ChildCommentItem> {
  void _highlightCommentWithBlurBG(BuildContext context, Widget child, Offset position) {
    final screenHeight = MediaQuery.of(context).size.height;
    final commentHeight = 80.0;
    final deleteRowHeight = 50.0;
    final padding = 5.0;

    final hasEnoughSpaceBelow = (position.dy + commentHeight + deleteRowHeight + padding) < screenHeight;

    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );

    final slideAnimation = Tween<double>(
      begin: hasEnoughSpaceBelow ? 0.0 : 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    ));

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    animationController.forward();

    OverlayManager().show(
      context: context,
      overlayId: OverlayIds.blurBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                animationController.reverse().then((_) {
                  OverlayManager().hide(OverlayIds.blurBg);
                  animationController.dispose(); // Clean up
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3), // Slight tint
                ),
              ),
            ),
            Positioned(
              top: !hasEnoughSpaceBelow ? position.dy - 75 : position.dy,
              left: position.dx,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, !hasEnoughSpaceBelow ? slideAnimation.value : 0),
                    child: Opacity(
                      opacity: opacityAnimation.value,
                      child: child,
                    ),
                  );
                },
              ),
            ),
            if (widget.childComment?.id != null && widget.childComment?.userId == userId)
              Positioned(
                top: position.dy + (!hasEnoughSpaceBelow ? 0 : 75),
                left: position.dx + 10,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, !hasEnoughSpaceBelow ? slideAnimation.value : 0),
                      child: Opacity(
                        opacity: opacityAnimation.value,
                        child: GestureDetector(
                          onTap: () {
                            OverlayManager().hide(OverlayIds.blurBg);
                            animationController.dispose();
                            postBloc.add(
                              DeleteCommentEvent(
                                postId: widget.postId,
                                commentId: widget.childComment?.id ?? '',
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                CustomText(
                                  'Delete',
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onLongPress: () {
        HapticFeedback.vibrate();
        final renderBox = widget.globalKey?.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);

        _highlightCommentWithBlurBG(
          context,
          SizedBox(
            width: renderBox.size.width + 10,
            child: HighlightedComment(
              comment: widget.childComment,
              postId: widget.postId,
            ),
          ),
          position,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () {
                    if (widget.childComment?.user?.id == userId) return;
                    appRouter.push(RouterName.otherUserProfile.path, extra: ProfileScreenDataModel(userId: widget.childComment?.user?.id ?? ''));
                  },
                  child: RoundProfileAvatar(
                    imageUrl: widget.childComment?.user?.profile?.profilePicture ?? '',
                    radius: 14,
                    userId: widget.childComment?.user?.id ?? '',
                  ),
                ),
                if (widget.childComment?.apiStatus == PostCommentApiStatus.posting)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                      ),
                    ),
                  ),
                if (widget.childComment?.apiStatus == PostCommentApiStatus.failure)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (widget.childComment?.user?.id == userId) return;
                              appRouter.push(RouterName.otherUserProfile.path,
                                  extra: ProfileScreenDataModel(userId: widget.childComment?.user?.id ?? ''));
                            },
                            child: Text(
                              widget.childComment?.user?.userName ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.childComment?.apiStatus == PostCommentApiStatus.posting) ...[
                            const CustomText(
                              'Posting...',
                              fontSize: 12,
                              color: Color(0xFF8B8B8B),
                              fontStyle: FontStyle.italic,
                            ),
                          ],
                          if (widget.childComment?.apiStatus == PostCommentApiStatus.deleting) ...[
                            const CustomText(
                              'Deleting...',
                              fontSize: 12,
                              color: Color(0xFF8B8B8B),
                              fontStyle: FontStyle.italic,
                            ),
                          ],
                          if (!([PostCommentApiStatus.posting, PostCommentApiStatus.failure, PostCommentApiStatus.deleting]
                              .contains(widget.childComment?.apiStatus))) ...[
                            Text(
                              DateFormatter.getRelativeTime(widget.childComment?.createdAt),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        widget.childComment?.comment ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (widget.childComment?.apiStatus == PostCommentApiStatus.failure) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              'Failed to post. ',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                postBloc.add(
                                  CreateCommentEvent(postId: widget.postId, comment: widget.childComment?.comment ?? '', userId: userId),
                                );
                              },
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (widget.childComment?.id != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              postBloc.add(ToggleCommentLikeEvent(
                                commentId: widget.childComment?.id ?? '',
                                isLike: !(widget.childComment?.isLiked ?? false),
                              ));
                            },
                            child: SvgPicture.asset(
                              (widget.childComment?.isLiked ?? false) ? AppAssets.heartFill : AppAssets.heart,
                              height: 18,
                              width: 18,
                              colorFilter: ColorFilter.mode(
                                (widget.childComment?.isLiked ?? false) ? Colors.red : Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          if ((widget.childComment?.likeCount ?? 0) != 0)
                            CustomText(
                              formattedCount(widget.childComment?.likeCount ?? 0),
                              fontSize: 11,
                            ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HighlightedComment extends StatelessWidget {
  final CommentData? comment;
  final String postId;
  const HighlightedComment({
    super.key,
    this.comment,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 11, right: 8, top: 11, bottom: 11),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundProfileAvatar(
            imageUrl: comment?.user?.profile?.profilePicture,
            radius: 18,
            userId: comment?.user?.id ?? '',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment?.user?.userName ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.getRelativeTime(comment?.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment?.comment ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentScreenDataModel {
  final String postId;
  final String postUserId;
  CommentScreenDataModel({
    required this.postId,
    required this.postUserId,
  });
}
