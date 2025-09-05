// Flutter
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

// Third-party
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";

// Project
import "package:pictora/core/utils/extensions/extensions.dart";
import '../../post.dart';
import "package:pictora/core/config/router.dart";
import "package:pictora/core/config/router_name.dart";
import "package:pictora/core/utils/constants/constants.dart";
import "package:pictora/core/utils/widgets/custom_widget.dart";
import 'package:shimmer/shimmer.dart';
import "../../../../core/utils/helper/helper.dart";
import "../../../profile/presentation/screens/profile_screen.dart";
import "post_media_display.dart";

class PostWidget extends StatefulWidget {
  final PostData? post;

  const PostWidget({
    super.key,
    required this.post,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with AutomaticKeepAliveClientMixin {
  PageController pageController = PageController();
  int currentMediaIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          PostMediaDisplay(
            mediaData: widget.post?.mediaData,
            postId: widget.post?.id ?? '',
            isLike: widget.post?.isLiked ?? false,
          ),
          _buildActionButtons(),
          _buildLikesSection(),
          if ((widget.post?.caption ?? '').isNotEmpty) _buildCaptionSection(),
          SizedBox(height: (widget.post?.caption ?? '').isNotEmpty ? 8 : 12),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (widget.post?.userData?.id == userId) return;
              appRouter.push(RouterName.otherUserProfile.path,
                  extra: ProfileScreenDataModel(
                    userId: widget.post?.userData?.id ?? '',
                    userName: widget.post?.userData?.userName ?? '',
                  ));
            },
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor,
                    width: 1.5,
                  )),
              child: RoundProfileAvatar(
                imageUrl: widget.post?.userData?.profile?.profilePicture,
                radius: 20,
                userId: widget.post?.userData?.id ?? '',
              ),
            ).withAutomaticKeepAlive(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                if (widget.post?.userData?.id == userId) return;
                appRouter.push(RouterName.otherUserProfile.path,
                    extra: ProfileScreenDataModel(
                      userId: widget.post?.userData?.id ?? '',
                      userName: widget.post?.userData?.userName ?? '',
                    ));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.post?.userData?.fullName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.timeAgoShort(widget.post?.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.public,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Public',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Enhanced more options button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_horiz, size: 20),
              color: Colors.grey[600],
              onPressed: () {
                _showPostOptions();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              postBloc.add(TogglePostLikeEvent(
                postId: widget.post?.id ?? '',
                isLike: !(widget.post?.isLiked ?? false),
              ));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                (widget.post?.isLiked ?? false) ? AppAssets.heartFill : AppAssets.heart,
                color: (widget.post?.isLiked ?? false) ? Colors.red : Colors.black87,
                height: 26,
                width: 26,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
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
                      postId: "${widget.post?.id}",
                      postUserId: widget.post?.userId ?? '',
                    ),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.comment,
                  color: Colors.black87,
                  height: 26,
                  width: 26,
                ),
                SizedBox(width: widget.post?.commentCount != 0 ? 3 : 5),
                if (widget.post?.commentCount != 0)
                  CustomText(
                    formattedCount(widget.post?.commentCount ?? 0),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
              ],
            ),
          ),
          SizedBox(width: widget.post?.commentCount != 0 ? 8 : 0),
          GestureDetector(
            onTap: () {
              postBloc.add(ToggleRePostEvent(
                postId: widget.post?.id ?? '',
                isRepost: !(widget.post?.isRepost ?? false),
              ));
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.repost,
                  color: Colors.black87,
                  height: 28,
                  width: 28,
                ),
                SizedBox(width: widget.post?.repostCount != 0 ? 3 : 5),
                if (widget.post?.repostCount != 0)
                  CustomText(
                    formattedCount(widget.post?.repostCount ?? 0),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
              ],
            ),
          ),
          SizedBox(width: widget.post?.repostCount != 0 ? 8 : 0),
          GestureDetector(
            onTap: () {},
            child: SvgPicture.asset(
              AppAssets.share,
              color: Colors.black87,
              height: 26,
              width: 26,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              postBloc.add(TogglePostSaveEvent(
                postId: widget.post?.id ?? '',
                isSave: !(widget.post?.isSaved ?? false),
              ));
            },
            child: SvgPicture.asset(
              (widget.post?.isSaved ?? false) ? AppAssets.saveFill : AppAssets.save,
              color: (widget.post?.isSaved ?? false) ? primaryColor : Colors.black87,
              height: 26,
              width: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesSection() {
    return InkWell(
      onTap: () {
        appRouter.push(RouterName.likedByUsers.path, extra: LikedByUserScreenDataModel(postId: widget.post?.id ?? ''));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomText(
          '${formattedCount(widget.post?.likeCount ?? 0)} likes',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCaptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '${widget.post?.userData?.userName} ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 14,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (widget.post?.userData?.id == userId) return;
                    appRouter.push(RouterName.otherUserProfile.path,
                        extra: ProfileScreenDataModel(
                          userId: widget.post?.userData?.id ?? '',
                          userName: widget.post?.userData?.userName ?? '',
                        ));
                  }),
            TextSpan(
              text: widget.post?.caption ?? '',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: bottomBarContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Divider
              Divider(
                height: 1,
                color: Colors.grey[200],
              ),

              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  children: [
                    // _buildModernBottomSheetOption(
                    //   context: context,
                    //   icon: Icons.bookmark_outline,
                    //   title: 'Save Post',
                    //   subtitle: 'Add this to your saved items',
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     // Handle save post
                    //   },
                    // ),
                    // const SizedBox(height: 8),
                    // _buildModernBottomSheetOption(
                    //   context: context,
                    //   icon: Icons.link,
                    //   title: 'Copy Link',
                    //   subtitle: 'Share this post with others',
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     // Handle copy link
                    //   },
                    // ),
                    // const SizedBox(height: 8),
                    _buildModernBottomSheetOption(
                      context: context,
                      icon: Icons.visibility_off_outlined,
                      title: 'Hide Post',
                      subtitle: 'See fewer posts like this',
                      onTap: () {
                        Navigator.pop(context);
                        // Handle hide post
                      },
                    ),
                    if (widget.post?.userId == userId) const SizedBox(height: 8),
                    if (widget.post?.userId == userId)
                      BlocBuilder<PostBloc, PostState>(
                        buildWhen: (previous, current) => previous.archivePostApiStatus != current.archivePostApiStatus,
                        builder: (context, state) {
                          return _buildModernBottomSheetOption(
                            context: context,
                            icon: Icons.archive_outlined,
                            title: (widget.post?.isArchived ?? false) ? "Unarchive" : 'Archive',
                            subtitle: (widget.post?.isArchived ?? false) ? "Move back from archive" : 'Move to your archive',
                            onTap: () {
                              postBloc.add(ArchivePostEvent(
                                postId: widget.post?.id ?? '',
                                isArchive: !(widget.post?.isArchived ?? false),
                              ));
                            },
                            showLoader: state.archivePostApiStatus == ApiStatus.loading,
                          );
                        },
                      ),

                    // Divider for destructive actions
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        height: 1,
                        color: Colors.grey[200],
                      ),
                    ),

                    _buildModernBottomSheetOption(
                      context: context,
                      icon: Icons.report_outlined,
                      title: 'Report',
                      subtitle: 'Report this post for review',
                      onTap: () {
                        Navigator.pop(context);
                        // Handle report
                      },
                      isDestructive: true,
                    ),
                    if (widget.post?.userId == userId) const SizedBox(height: 8),
                    if (widget.post?.userId == userId)
                      _buildModernBottomSheetOption(
                        context: context,
                        icon: Icons.delete_outline,
                        title: 'Delete',
                        subtitle: 'Permanently remove this post',
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation();
                        },
                        isDestructive: true,
                      ),
                  ],
                ),
              ),

              // Bottom padding for safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernBottomSheetOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showLoader = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDestructive ? Colors.red.withValues(alpha: 0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isDestructive ? Colors.red[600] : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? Colors.red[600] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDestructive ? Colors.red[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              showLoader
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[400],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: bottomBarContext!,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 32,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Delete Post?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Content
              Text(
                'This post will be permanently deleted and cannot be recovered. Are you sure you want to continue?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      textColor: Colors.black,
                      borderColor: Colors.grey.shade300,
                      onTap: () {
                        appRouter.pop();
                      },
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<PostBloc, PostState>(
                    buildWhen: (previous, current) => previous.deletePostApiStatus != current.deletePostApiStatus,
                    builder: (context, state) {
                      return Expanded(
                        child: CustomButton(
                          text: "Delete",
                          onTap: () {
                            postBloc.add(DeletePostEvent(postId: widget.post?.id ?? ''));
                          },
                          backgroundColor: Colors.red,
                          showLoader: state.deletePostApiStatus == ApiStatus.loading,
                        ),
                      );
                    },
                  ),
                ],
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

class ShimmerPostWidget extends StatelessWidget {
  const ShimmerPostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerHeader(),
          _buildShimmerMedia(),
          _buildShimmerActions(),
          _buildShimmerLikes(),
          _buildShimmerCaption(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 180,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerMedia() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 375,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 26,
              height: 26,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLikes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 100,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 250,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
