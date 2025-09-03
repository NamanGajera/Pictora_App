// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import 'package:pictora/core/utils/extensions/extensions.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../profile/profile.dart';
import '../../models/post_data.dart';

class ReelUserAndPostInfoSection extends StatelessWidget {
  final PostData reel;
  const ReelUserAndPostInfoSection({super.key, required this.reel});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> showFullCaption = ValueNotifier(false);

    return Column(
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
            valueListenable: showFullCaption,
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () {
                  showFullCaption.value = !showFullCaption.value;
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
}
