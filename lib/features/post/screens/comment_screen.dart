import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';
import 'package:pictora/features/post/models/post_comment_data_model.dart';
import 'package:pictora/utils/constants/bloc_instances.dart';
import 'package:pictora/utils/constants/constants.dart';
import 'package:pictora/utils/extensions/build_context_extension.dart';

import '../../../utils/constants/app_assets.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/overlay_ids.dart';
import '../../../utils/helper/date_formatter.dart';
import '../../../utils/helper/helper_function.dart';
import '../../../utils/widgets/custom_overlay.dart';
import '../../../utils/widgets/custom_widget.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<GlobalKey> commentKeys = [];

  @override
  void initState() {
    super.initState();
    postBloc.add(GetPostCommentDataEvent(postId: widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    selectedCommentId.value = null;
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    if (selectedCommentId.value != null) {
      // communityBloc.add(
      //   AddCommentReplyEvent(
      //     postId: widget.postId,
      //     comment: _commentController.text.trim(),
      //     userName: userName ?? '',
      //     profilePic: userProfilePic ?? '',
      //     commentId: selectedCommentId.value ?? '',
      //   ),
      // );
    } else {
      // communityBloc.add(
      //   AddCommentEvent(
      //     postId: widget.postId,
      //     comment: _commentController.text.trim(),
      //     userName: userName ?? '',
      //     profilePic: userProfilePic ?? '',
      //   ),
      // );
    }
    selectedCommentId.value = null;
    _commentController.clear();
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
                              // communityBloc.add(FetchAllCommentEvent(postId: widget.postId));
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: (state.commentDataList ?? []).length,
                              itemBuilder: (context, index) {
                                CommentData? comment = state.commentDataList?[index];
                                return GestureDetector(
                                  onDoubleTap: () {
                                    if (comment?.id == null) return;
                                    // communityBloc.add(ToggleCommentLikeEvent(commentId: comment?.id ?? '', isLike: !(comment?.isLiked ?? false)));
                                  },
                                  child: CommentItem(
                                    key: commentKeys[index],
                                    globalKey: commentKeys[index],
                                    comment: comment,
                                    postId: widget.postId,
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
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(AppAssets.profilePng),
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
                  color: _commentController.text.trim().isEmpty ? primaryColor.withOpacity(0.8) : Theme.of(context).primaryColor,
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

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
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
                  color: Colors.black.withOpacity(0.3), // Slight tint
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
            // if (widget.comment?.id != null && widget.comment?.user?.userId == appUserId)
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
                      child: GestureDetector(
                        onTap: () {
                          OverlayManager().hide(OverlayIds.blurBg);
                          animationController.dispose();
                          // communityBloc.add(
                          //   DeleteCommentEvent(
                          //     postId: widget.postId,
                          //     commentId: widget.comment?.id ?? '',
                          //     isReply: false,
                          //   ),
                          // );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200, // Optional background color
                  child: ClipOval(
                    child: CachedNetworkImage(
                      // imageUrl: widget.comment?.user?.profilePic ?? '',
                      imageUrl: '',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        AppAssets.profile,
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        AppAssets.profile,
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36,
                      ),
                    ),
                  ),
                ),
                // if (widget.comment?.postCommentApiStatus == PostCommentApiStatus.posting)
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
                // if (widget.comment?.postCommentApiStatus == PostCommentApiStatus.failure)
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
                      Row(
                        children: [
                          Text(
                            widget.comment?.user?.username ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // if (widget.comment?.postCommentApiStatus == PostCommentApiStatus.posting) ...[
                          const CustomText(
                            'Posting...',
                            fontSize: 12,
                            color: Color(0xFF8B8B8B),
                            fontStyle: FontStyle.italic,
                          ),
                          // ],
                          // if (widget.comment?.postCommentApiStatus == PostCommentApiStatus.deleting) ...[
                          const CustomText(
                            'Deleting...',
                            fontSize: 12,
                            color: Color(0xFF8B8B8B),
                            fontStyle: FontStyle.italic,
                          ),
                          // ],
                          // if (!([PostCommentApiStatus.posting, PostCommentApiStatus.failure, PostCommentApiStatus.deleting].contains(widget.comment?.postCommentApiStatus))) ...[
                          Text(
                            DateFormatter.getRelativeTime(widget.comment?.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          // ],
                        ],
                      ),
                      if (widget.comment?.userId == userId) const SizedBox(height: 4),
                      Text(
                        widget.comment?.comment ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                      // if (widget.comment?.postCommentApiStatus == PostCommentApiStatus.failure) ...[
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
                              // communityBloc.add(
                              //   AddCommentEvent(
                              //     postId: widget.postId,
                              //     comment: widget.comment?.commentText ?? '',
                              //     userName: userName ?? '',
                              //     profilePic: userProfilePic ?? '',
                              //   ),
                              // );
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
                      // ],
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
                      Column(
                        children: [
                          SizedBox(height: 8),
                          InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              // communityBloc.add(ToggleSelectCommentEvent(commentId: widget.comment?.id ?? ''));
                            },
                            child: CustomText(
                              'View ${formattedCount(widget.comment?.repliesCount ?? 0)} more reply',
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      // if ((widget.comment?.childComment ?? []).isNotEmpty) ...[
                      //   BlocBuilder<PostBloc, PostState>(
                      //     builder: (context, state) {
                      //       return (state.selectedCommentIds ?? {}).contains(widget.comment?.id)
                      //           ? Column(
                      //               children: [
                      //                 ListView.builder(
                      //                   itemCount: (widget.comment?.childComment ?? []).length,
                      //                   shrinkWrap: true,
                      //                   padding: EdgeInsets.only(top: 10, bottom: 10),
                      //                   physics: NeverScrollableScrollPhysics(),
                      //                   itemBuilder: (context, replyIndex) {
                      //                     childCommentKeys = List.generate((widget.comment?.childComment ?? []).length, (_) => GlobalKey());
                      //                     final ChildComment? childComment = widget.comment?.childComment?[replyIndex];

                      //                     return InkWell(
                      //                         splashColor: Colors.transparent,
                      //                         highlightColor: Colors.transparent,
                      //                         onDoubleTap: () {
                      //                           if (childComment?.id == null) return;
                      //                           communityBloc.add(ToggleCommentLikeEvent(commentId: childComment?.id ?? '', isLike: !(childComment?.isLiked ?? false)));
                      //                         },
                      //                         child: ChildCommentItem(
                      //                           childComment: childComment,
                      //                           postId: widget.postId,
                      //                           key: childCommentKeys[replyIndex],
                      //                           globalKey: childCommentKeys[replyIndex],
                      //                           parentCommentId: widget.comment?.id ?? '',
                      //                         ));
                      //                   },
                      //                 )
                      //               ],
                      //             )
                      //           :
                      //           Column(
                      //               children: [
                      //                 SizedBox(height: 8),
                      //                 InkWell(
                      //                   splashColor: Colors.transparent,
                      //                   highlightColor: Colors.transparent,
                      //                   onTap: () {
                      //                     // communityBloc.add(ToggleSelectCommentEvent(commentId: widget.comment?.id ?? ''));
                      //                   },
                      //                   child: CustomText(
                      //                     'View ${formattedCount(widget.comment?.repliesCount ?? 0)} more reply',
                      //                     fontSize: 12,
                      //                     color: Colors.grey.shade400,
                      //                   ),
                      //                 ),
                      //               ],
                      //             );
                      //     },
                      //   )
                      // ],
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
                              // communityBloc.add(ToggleCommentLikeEvent(commentId: widget.comment?.id ?? '', isLike: !(widget.comment?.isLiked ?? false)));
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

// class ChildCommentItem extends StatefulWidget {
//   final ChildComment? childComment;
//   final String postId;
//   final String parentCommentId;
//   final GlobalKey? globalKey;
//   const ChildCommentItem({
//     super.key,
//     required this.childComment,
//     required this.globalKey,
//     required this.postId,
//     required this.parentCommentId,
//   });

//   @override
//   State<ChildCommentItem> createState() => _ChildCommentItemState();
// }

// class _ChildCommentItemState extends State<ChildCommentItem> {
//   void _highlightCommentWithBlurBG(BuildContext context, Widget child, Offset position) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final commentHeight = 80.0;
//     final deleteRowHeight = 50.0;
//     final padding = 5.0;

//     final hasEnoughSpaceBelow = (position.dy + commentHeight + deleteRowHeight + padding) < screenHeight;

//     final animationController = AnimationController(
//       vsync: Navigator.of(context),
//       duration: const Duration(milliseconds: 300),
//     );

//     final slideAnimation = Tween<double>(
//       begin: hasEnoughSpaceBelow ? 0.0 : 50.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeOutBack,
//     ));

//     final opacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeOut,
//     ));

//     // Start animation
//     animationController.forward();

//     OverlayManager().show(
//       context: context,
//       overlayId: OverlayIds.blurBg,
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Stack(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 animationController.reverse().then((_) {
//                   OverlayManager().hide(OverlayIds.blurBg);
//                   animationController.dispose(); // Clean up
//                 });
//               },
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                 child: Container(
//                   color: Colors.black.withOpacity(0.3), // Slight tint
//                 ),
//               ),
//             ),
//             Positioned(
//               top: !hasEnoughSpaceBelow ? position.dy - 75 : position.dy,
//               left: position.dx,
//               child: AnimatedBuilder(
//                 animation: animationController,
//                 builder: (context, _) {
//                   return Transform.translate(
//                     offset: Offset(0, !hasEnoughSpaceBelow ? slideAnimation.value : 0),
//                     child: Opacity(
//                       opacity: opacityAnimation.value,
//                       child: child,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             if (widget.childComment?.id != null && widget.childComment?.user?.userId == appUserId)
//               Positioned(
//                 top: position.dy + (!hasEnoughSpaceBelow ? 0 : 75),
//                 left: position.dx + 10,
//                 child: AnimatedBuilder(
//                   animation: animationController,
//                   builder: (context, _) {
//                     return Transform.translate(
//                       offset: Offset(0, !hasEnoughSpaceBelow ? slideAnimation.value : 0),
//                       child: Opacity(
//                         opacity: opacityAnimation.value,
//                         child: GestureDetector(
//                           onTap: () {
//                             OverlayManager().hide(OverlayIds.blurBg);
//                             animationController.dispose();
//                             communityBloc.add(
//                               DeleteCommentEvent(
//                                 postId: widget.postId,
//                                 commentId: widget.childComment?.id ?? '',
//                                 isReply: true,
//                                 parentCommentId: widget.parentCommentId,
//                               ),
//                             );
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   spreadRadius: 1,
//                                   blurRadius: 5,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.delete,
//                                   color: Colors.red,
//                                   size: 20,
//                                 ),
//                                 SizedBox(width: 8),
//                                 CustomText(
//                                   'Delete',
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w400,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       splashColor: Colors.transparent,
//       highlightColor: Colors.transparent,
//       onLongPress: () {
//         HapticFeedback.vibrate();
//         final renderBox = widget.globalKey?.currentContext!.findRenderObject() as RenderBox;
//         final position = renderBox.localToGlobal(Offset.zero);

//         _highlightCommentWithBlurBG(
//           context,
//           SizedBox(
//             width: renderBox.size.width + 10,
//             child: HighlightedComment(
//               childComment: widget.childComment,
//               postId: widget.postId,
//             ),
//           ),
//           position,
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.grey.shade200, // Optional background color
//                   child: ClipOval(
//                     child: CachedNetworkImage(
//                       imageUrl: widget.childComment?.user?.profilePic ?? '',
//                       width: 26,
//                       height: 26,
//                       fit: BoxFit.cover,
//                       placeholder: (context, url) => Image.asset(
//                         AppAssets.profile,
//                         fit: BoxFit.cover,
//                         width: 26,
//                         height: 26,
//                       ),
//                       errorWidget: (context, url, error) => Image.asset(
//                         AppAssets.profile,
//                         fit: BoxFit.cover,
//                         width: 26,
//                         height: 26,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (widget.childComment?.postCommentApiStatus == PostCommentApiStatus.posting)
//                   Positioned(
//                     right: 0,
//                     bottom: 0,
//                     child: Container(
//                       width: 12,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: Colors.amber,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
//                       ),
//                     ),
//                   ),
//                 if (widget.childComment?.postCommentApiStatus == PostCommentApiStatus.failure)
//                   Positioned(
//                     right: -2,
//                     bottom: -2,
//                     child: Container(
//                       width: 16,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
//                       ),
//                       child: const Icon(
//                         Icons.error_outline,
//                         color: Colors.white,
//                         size: 10,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Stack(
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             widget.childComment?.user?.name ?? '',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           if (widget.childComment?.postCommentApiStatus == PostCommentApiStatus.posting) ...[
//                             const CustomText(
//                               'Posting...',
//                               fontSize: 12,
//                               color: Color(0xFF8B8B8B),
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ],
//                           if (widget.childComment?.postCommentApiStatus == PostCommentApiStatus.deleting) ...[
//                             const CustomText(
//                               'Deleting...',
//                               fontSize: 12,
//                               color: Color(0xFF8B8B8B),
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ],
//                           if (!([PostCommentApiStatus.posting, PostCommentApiStatus.failure, PostCommentApiStatus.deleting].contains(widget.childComment?.postCommentApiStatus))) ...[
//                             Text(
//                               DateFormatter.getRelativeTime(widget.childComment?.createdDate),
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       Text(
//                         widget.childComment?.commentText ?? '',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       if (widget.childComment?.postCommentApiStatus == PostCommentApiStatus.failure) ...[
//                         const SizedBox(height: 3),
//                         Row(
//                           children: [
//                             Text(
//                               'Failed to post. ',
//                               style: TextStyle(
//                                 color: Colors.red.shade400,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 communityBloc.add(
//                                   AddCommentEvent(
//                                     postId: widget.postId,
//                                     comment: widget.childComment?.commentText ?? '',
//                                     userName: userName ?? '',
//                                     profilePic: userProfilePic ?? '',
//                                   ),
//                                 );
//                               },
//                               child: Text(
//                                 'Retry',
//                                 style: TextStyle(
//                                   color: Theme.of(context).primaryColor,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                   if (widget.childComment?.id != null)
//                     Positioned(
//                       right: 0,
//                       top: 0,
//                       bottom: 0,
//                       child: Column(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               communityBloc.add(ToggleCommentLikeEvent(commentId: widget.childComment?.id ?? '', isLike: !(widget.childComment?.isLiked ?? false)));
//                             },
//                             child: SvgPicture.asset(
//                               (widget.childComment?.isLiked ?? false) ? AppAssets.likeFillIcon : AppAssets.likeIcon,
//                               height: 18,
//                               width: 18,
//                               colorFilter: ColorFilter.mode(
//                                 (widget.childComment?.isLiked ?? false) ? Colors.red : Colors.black,
//                                 BlendMode.srcIn,
//                               ),
//                             ),
//                           ),
//                           if ((widget.childComment?.likeCount ?? 0) != 0)
//                             CustomText(
//                               formattedCount(widget.childComment?.likeCount ?? 0),
//                               fontSize: 11,
//                             ),
//                         ],
//                       ),
//                     )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class HighlightedComment extends StatelessWidget {
  final CommentData? comment;
  // final ChildComment? childComment;
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
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: CachedNetworkImage(
                // imageUrl: comment?.user?.profilePic ?? childComment?.user?.profilePic ?? '',
                imageUrl: comment?.user?.profile?.profilePicture ?? '',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  AppAssets.profile,
                  fit: BoxFit.cover,
                  width: 36,
                  height: 36,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  AppAssets.profile,
                  fit: BoxFit.cover,
                  width: 36,
                  height: 36,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      // comment?.user?.name ?? childComment?.user?.name ?? '',
                      comment?.user?.username ?? '',
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
                  // comment?.commentText ?? childComment?.commentText ?? '',
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

class CommunityPostCommentScreenDataModel {
  final String postId;
  CommunityPostCommentScreenDataModel({required this.postId});
}
