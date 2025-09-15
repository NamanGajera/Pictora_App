import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/router.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../conversation.dart';

class MessageScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ConversationData? conversationData;
  const MessageScreenAppBar({super.key, required this.conversationData});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              RoundProfileAvatar(
                radius: 18,
                userId: '',
                imageUrl: conversationData?.otherUser?[0].userData?.profile?.profilePicture ?? '',
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: BlocBuilder<ConversationBloc, ConversationState>(
                  buildWhen: (previous, current) => previous.onlineUserIds != current.onlineUserIds,
                  builder: (context, state) {
                    final bool isOnline = (state.onlineUserIds ?? []).contains(conversationData?.otherUser?[0].userId);
                    if (!isOnline) {
                      return SizedBox.shrink();
                    }
                    return Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: const Color(0XFF3EB838),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          CustomText(
            conversationData?.title ?? conversationData?.otherUser?[0].userData?.fullName ?? '',
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 18,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => appRouter.pop(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
