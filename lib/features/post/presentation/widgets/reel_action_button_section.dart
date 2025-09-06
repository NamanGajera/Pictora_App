// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Project
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../post.dart';

class ReelActionButtonSection extends StatelessWidget {
  final PostData reel;
  const ReelActionButtonSection({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: (previous, current) => previous.reelsData != current.reelsData,
      builder: (context, state) {
        final reelData = (state.reelsData ?? []).firstWhere((r) => r.id == reel.id, orElse: () => PostData());
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                postBloc.add(TogglePostLikeEvent(
                  postId: reelData.id ?? '',
                  isLike: !(reelData.isLiked ?? false),
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(
                    (reelData.isLiked ?? false) ? AppAssets.heartFill : AppAssets.heart,
                    color: (reelData.isLiked ?? false) ? Colors.red : Colors.white,
                    height: 32,
                    width: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            CustomText(
              formattedCount(reelData.likeCount ?? 0),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.white,
            ),
            if (reelData.userId != userId) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  postBloc.add(TogglePostLikeEvent(
                    postId: reelData.id ?? '',
                    isLike: !(reelData.isRepost ?? false),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: SvgPicture.asset(
                      AppAssets.repost,
                      color: (reelData.isRepost ?? false) ? Colors.red : Colors.white,
                      height: 32,
                      width: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              CustomText(
                formattedCount(reelData.repostCount ?? 0),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white,
              ),
            ],
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
                        postId: "${reelData.id}",
                        postUserId: reelData.userId ?? '',
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
            if (reelData.commentCount != 0) ...[
              const SizedBox(height: 2),
              CustomText(
                formattedCount(reelData.commentCount ?? 0),
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white,
              ),
            ],
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                postBloc.add(TogglePostSaveEvent(
                  postId: reelData.id ?? '',
                  isSave: !(reelData.isSaved ?? false),
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  (reelData.isSaved ?? false) ? AppAssets.saveFill : AppAssets.save,
                  color: Colors.white,
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
            // const SizedBox(height: 12),
            // GestureDetector(
            //   onTap: () {
            //     _showPostOptions(reelData);
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     child: const Icon(
            //       Icons.more_vert,
            //       color: Colors.white,
            //       size: 32,
            //     ),
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
