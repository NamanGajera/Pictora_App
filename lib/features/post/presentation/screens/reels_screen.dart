// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Project
import 'package:pictora/core/utils/extensions/extensions.dart';
import 'package:pictora/core/utils/widgets/custom_widget.dart';
import 'package:pictora/features/post/models/models.dart';
import '../../../../core/config/router.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/utils/services/service.dart';
import '../../../profile/profile.dart';
import '../../bloc/post_bloc.dart';
import '../widgets/reel_display.dart';
import 'comment_screen.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => ReelsScreenState();
}

class ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<bool> _showFullCaption = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    postBloc.add(GetAllReelsEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    if (_pageController.hasClients) {
      reelRefreshKey.currentState?.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        key: reelRefreshKey,
        onRefresh: () async {
          postBloc.add(GetAllReelsEvent());
        },
        child: BlocBuilder<PostBloc, PostState>(
          buildWhen: (previous, current) => previous.getReelApiStatus != current.getReelApiStatus || previous.reelsData != current.reelsData,
          builder: (context, state) {
            final reelData = state.reelsData ?? [];

            if (reelData.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: reelData.length,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                if (index + 1 < reelData.length) {
                  final nextUrl = reelData[index + 1].mediaData?[0].mediaUrl;
                  if (nextUrl != null) {
                    VideoControllerManager.getController(nextUrl).catchError((e) {
                      logDebug(message: "Failed to preload next video: $e");
                    });
                  }
                }

                final keepUrls = <String>{};
                for (int offset = -2; offset <= 2; offset++) {
                  final i = index + offset;
                  if (i >= 0 && i < reelData.length) {
                    final url = reelData[i].mediaData?[0].mediaUrl;
                    if (url != null) keepUrls.add(url);
                  }
                }

                VideoControllerManager.retainOnly(keepUrls);

                if (index >= reelData.length - 4 && state.hasMoreReel) {
                  postBloc.add(
                    LoadMoreReelsEvent(body: {"skip": state.reelsData?.length, "take": 20}),
                  );
                }
              },
              itemBuilder: (context, index) {
                if (!mounted) return const SizedBox();
                final reel = reelData[index];
                return SizedBox(
                  height: context.screenHeight,
                  width: context.screenWidth,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ReelsMediaDisplay(
                          mediaData: reel.mediaData,
                          postId: reel.id ?? '',
                          isLike: reel.isLiked ?? false,
                          key: PageStorageKey(reel.id),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 30,
                        right: context.screenWidth * 0.25,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: RoundProfileAvatar(
                                    imageUrl: reel.userData?.profile?.profilePicture,
                                    radius: 22,
                                    userId: reel.userId ?? '',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomText(
                                    reel.userData?.userName ?? 'Unknown User',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                if (reel.userId != userId) _buildActionButtons(reel.userData, reel.id),
                              ],
                            ),
                            if ((reel.caption ?? '').isNotEmpty) const SizedBox(height: 10),
                            if ((reel.caption ?? '').isNotEmpty)
                              ValueListenableBuilder(
                                valueListenable: _showFullCaption,
                                builder: (context, value, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showFullCaption.value = !_showFullCaption.value;
                                    },
                                    child: Text(
                                      reel.caption ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: value ? null : 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 30,
                        child: _buildVerticalActionButtons(reel),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerticalActionButtons(PostData? reel) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            postBloc.add(TogglePostLikeEvent(
              postId: reel?.id ?? '',
              isLike: !(reel?.isLiked ?? false),
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: SvgPicture.asset(
                (reel?.isLiked ?? false) ? AppAssets.heartFill : AppAssets.heart,
                color: (reel?.isLiked ?? false) ? Colors.red : Colors.white,
                height: 32,
                width: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        CustomText(
          formattedCount(reel?.likeCount ?? 0),
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.white,
        ),
        const SizedBox(height: 12),
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
                    postId: "${reel?.id}",
                    postUserId: reel?.userId ?? '',
                  ),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              AppAssets.comment,
              color: Colors.white,
              height: 32,
              width: 32,
            ),
          ),
        ),
        if (reel?.commentCount != 0) ...[
          const SizedBox(height: 2),
          CustomText(
            formattedCount(reel?.commentCount ?? 0),
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.white,
          ),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            postBloc.add(TogglePostSaveEvent(
              postId: reel?.id ?? '',
              isSave: !(reel?.isSaved ?? false),
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              (reel?.isSaved ?? false) ? AppAssets.saveFill : AppAssets.save,
              color: (reel?.isSaved ?? false) ? primaryColor : Colors.white,
              height: 32,
              width: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              AppAssets.share,
              color: Colors.white,
              height: 32,
              width: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            _showPostOptions(reel);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(User? userData, String? postId) {
    return BlocBuilder<FollowSectionBloc, FollowSectionState>(
      builder: (context, state) {
        final buttonWidth = context.screenWidth * 0.22;

        if (userData?.followRequestStatus == FollowRequest.pending.name) {
          return CustomButton(
            width: buttonWidth,
            height: 32,
            textColor: Colors.white,
            backgroundColor: Colors.transparent,
            borderColor: Colors.white,
            text: "Requested",
            fontSize: 14,
            onTap: () {
              followSectionBloc.add(ToggleFollowUserEvent(
                userId: userData?.id ?? '',
                isFollowing: false,
                isPrivate: userData?.profile?.isPrivate ?? false,
                postId: postId,
              ));
            },
          );
        } else if (userData?.isFollowed == true) {
          return CustomButton(
            width: buttonWidth,
            height: 32,
            textColor: Colors.white,
            backgroundColor: Colors.transparent,
            borderColor: Colors.white,
            text: "Following",
            fontSize: 14,
            onTap: () {
              followSectionBloc.add(ToggleFollowUserEvent(
                userId: userData?.id ?? '',
                isFollowing: false,
                isPrivate: userData?.profile?.isPrivate ?? false,
                postId: postId,
              ));
            },
          );
        } else if (userData?.showFollowBack == true) {
          return CustomButton(
            width: buttonWidth,
            height: 32,
            textColor: Colors.white,
            backgroundColor: Colors.transparent,
            borderColor: Colors.white,
            text: "Follow Back",
            fontSize: 14,
            onTap: () {
              followSectionBloc.add(ToggleFollowUserEvent(
                userId: userData?.id ?? '',
                isFollowing: true,
                isPrivate: userData?.profile?.isPrivate ?? false,
                postId: postId,
              ));
            },
          );
        } else {
          return CustomButton(
            width: buttonWidth,
            height: 32,
            textColor: Colors.white,
            backgroundColor: Colors.transparent,
            borderColor: Colors.white,
            text: "Follow",
            fontSize: 14,
            onTap: () {
              followSectionBloc.add(ToggleFollowUserEvent(
                userId: userData?.id ?? '',
                isFollowing: true,
                isPrivate: userData?.profile?.isPrivate ?? false,
                postId: postId,
              ));
            },
          );
        }
      },
    );
  }

  void _showPostOptions(PostData? reel) {
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
                    if (reel?.userId == userId) const SizedBox(height: 8),
                    if (reel?.userId == userId)
                      BlocBuilder<PostBloc, PostState>(
                        buildWhen: (previous, current) => previous.archivePostApiStatus != current.archivePostApiStatus,
                        builder: (context, state) {
                          return _buildModernBottomSheetOption(
                            context: context,
                            icon: Icons.archive_outlined,
                            title: (reel?.isArchived ?? false) ? "Unarchive" : 'Archive',
                            subtitle: (reel?.isArchived ?? false) ? "Move back from archive" : 'Move to your archive',
                            onTap: () {
                              postBloc.add(ArchivePostEvent(
                                postId: reel?.id ?? '',
                                isArchive: !(reel?.isArchived ?? false),
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
                    if (reel?.userId == userId) const SizedBox(height: 8),
                    if (reel?.userId == userId)
                      _buildModernBottomSheetOption(
                        context: context,
                        icon: Icons.delete_outline,
                        title: 'Delete',
                        subtitle: 'Permanently remove this post',
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(reel);
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

  void _showDeleteConfirmation(PostData? reel) {
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
                            postBloc.add(DeletePostEvent(postId: reel?.id ?? ''));
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
}
