import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:pictora/features/post/screens/comment_screen.dart";
import "package:pictora/utils/constants/app_assets.dart";
import "package:pictora/utils/widgets/custom_widget.dart";

import "../../../../utils/constants/colors.dart";
import "../../../../utils/constants/constants.dart";
import "../../../../utils/helper/date_formatter.dart";
import "../../models/post_data.dart";
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

class _PostWidgetState extends State<PostWidget> {
  PageController pageController = PageController();
  int currentMediaIndex = 0;

  @override
  Widget build(BuildContext context) {
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
          ),
          _buildActionButtons(),
          _buildLikesSection(),
          _buildCaptionSection(),
          _buildCommentsSection(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                backgroundImage: (widget.post?.userData?.profile?.profilePicture ?? '').isNotEmpty
                    ? NetworkImage(widget.post?.userData?.profile?.profilePicture ?? '')
                    : null,
                child:
                    (widget.post?.userData?.profile?.profilePicture ?? '').isEmpty ? const Icon(Icons.person, color: primaryColor, size: 20) : null,
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
                      widget.post?.userData?.fullName ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Verified badge (optional)
                    // Icon(
                    //   Icons.verified,
                    //   size: 16,
                    //   color: primaryColor,
                    // ),
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
            onTap: () {},
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
          const SizedBox(width: 16),
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
                SizedBox(width: widget.post?.commentCount != 0 ? 8 : 5),
                if (widget.post?.commentCount != 0)
                  CustomText(
                    _formatNumber(widget.post?.commentCount ?? 0),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
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
            onTap: () {},
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomText(
        '${_formatNumber(widget.post?.likeCount ?? 0)} likes',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Colors.black87,
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
            ),
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

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'View all ${widget.post?.commentCount} comments',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetOption(
                icon: Icons.link,
                title: 'Copy Link',
                onTap: () {
                  Navigator.pop(context);
                  // Handle copy link
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.report_outlined,
                title: 'Report',
                onTap: () {
                  Navigator.pop(context);
                  // Handle report
                },
                isDestructive: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
