// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import 'package:pictora/core/utils/extensions/extensions.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/config/router.dart';
import '../../../../core/config/router_name.dart';
import '../../bloc/follow_section_bloc/follow_section_bloc.dart';
import '../screens/follow_section_screen.dart';

class DiscoverUserCard extends StatefulWidget {
  final User user;
  final bool isLast;
  final List<User>? randomTwoUsers;

  const DiscoverUserCard({
    super.key,
    required this.user,
    this.isLast = false,
    this.randomTwoUsers,
  });

  @override
  State<DiscoverUserCard> createState() => _DiscoverUserCardState();
}

class _DiscoverUserCardState extends State<DiscoverUserCard> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      key: ValueKey("discover_${widget.user.id}"),
      width: 180,
      margin: const EdgeInsets.only(top: 6, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.isLast
              ? SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if ((widget.randomTwoUsers ?? []).isNotEmpty)
                        Positioned(
                          left: -15,
                          top: 10,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: RoundProfileAvatar(
                              imageUrl: widget.randomTwoUsers![0].profile?.profilePicture,
                              radius: 38,
                              userId: widget.randomTwoUsers?[0].id ?? '',
                            ),
                          ),
                        ),
                      if (widget.randomTwoUsers != null && widget.randomTwoUsers!.length > 1)
                        Positioned(
                          top: 18,
                          left: 5,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: RoundProfileAvatar(
                              imageUrl: widget.randomTwoUsers![1].profile?.profilePicture,
                              radius: 38,
                              userId: widget.randomTwoUsers?[1].id ?? '',
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : RoundProfileAvatar(
                  imageUrl: widget.user.profile?.profilePicture ?? '',
                  radius: 42,
                  userId: widget.user.id ?? '',
                ),
          const SizedBox(height: 8),
          if (!widget.isLast)
            Text(
              widget.user.userName ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            widget.isLast ? "Find more user to follow" : widget.user.fullName ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: widget.isLast ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ).withPadding(widget.isLast ? const EdgeInsets.only(left: 40, right: 40, top: 10) : EdgeInsets.zero),
          const SizedBox(height: 12),
          BlocBuilder<FollowSectionBloc, FollowSectionState>(
            builder: (context, state) {
              if (widget.isLast) {
                return CustomButton(
                  width: 150,
                  height: 33,
                  text: "See all",
                  fontSize: 13,
                  onTap: () {
                    appRouter.push(
                      RouterName.followSection.path,
                      extra: FollowSectionScreenDataModel(
                        userId: userId ?? '',
                        userName: userName ?? '',
                        tabIndex: 3,
                      ),
                    );
                  },
                );
              } else if (widget.user.followRequestStatus == FollowRequest.pending.name) {
                return CustomButton(
                  width: 150,
                  height: 33,
                  text: "Requested",
                  fontSize: 13,
                  onTap: () {
                    followSectionBloc.add(ToggleFollowUserEvent(
                      userId: widget.user.id ?? '',
                      isFollowing: false,
                      isPrivate: widget.user.profile?.isPrivate ?? false,
                    ));
                  },
                );
              } else if (widget.user.isFollowed == true) {
                return CustomButton(
                  width: 150,
                  height: 33,
                  text: "Following",
                  textColor: Colors.grey.shade600,
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.grey,
                  fontSize: 13,
                  onTap: () {
                    followSectionBloc.add(ToggleFollowUserEvent(
                      userId: widget.user.id ?? '',
                      isFollowing: false,
                    ));
                  },
                );
              } else if (widget.user.showFollowBack == true) {
                return CustomButton(
                  width: 150,
                  height: 33,
                  text: "Follow Back",
                  textColor: Colors.white,
                  backgroundColor: primaryColor,
                  borderColor: primaryColor,
                  fontSize: 13,
                  onTap: () {
                    followSectionBloc.add(ToggleFollowUserEvent(
                      userId: widget.user.id ?? '',
                      isFollowing: true,
                      isPrivate: widget.user.profile?.isPrivate ?? false,
                    ));
                  },
                );
              } else {
                return CustomButton(
                  width: 150,
                  height: 33,
                  text: "Follow",
                  textColor: Colors.white,
                  backgroundColor: primaryColor,
                  borderColor: primaryColor,
                  fontSize: 13,
                  onTap: () {
                    followSectionBloc.add(ToggleFollowUserEvent(
                      userId: widget.user.id ?? '',
                      isFollowing: true,
                      isPrivate: widget.user.profile?.isPrivate ?? false,
                    ));
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
