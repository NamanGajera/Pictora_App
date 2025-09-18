import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/core/utils/constants/constants.dart';

import '../../../../core/utils/widgets/custom_widget.dart';
import '../../conversation.dart';

class ConversationCardView extends StatefulWidget {
  final ConversationData? conversationData;

  const ConversationCardView({
    super.key,
    this.conversationData,
  });

  @override
  State<ConversationCardView> createState() => _ConversationCardViewState();
}

class _ConversationCardViewState extends State<ConversationCardView> {
  @override
  void initState() {
    super.initState();
    getLastMessage();
  }

  @override
  void didUpdateWidget(ConversationCardView oldWidget) {
    super.didUpdateWidget(oldWidget);

    getLastMessage();
  }

  IconData? attachmentIcon;
  String? lastMessage;

  void getLastMessage() {
    if ((widget.conversationData?.lastMessage?.attachments ?? []).isNotEmpty) {
      MessageAttachments? firstAttachment = (widget.conversationData?.lastMessage?.attachments ?? []).first;

      if (firstAttachment.type == ConversationMessageAttachmentType.image.name) {
        attachmentIcon = Icons.image;
        lastMessage = ((widget.conversationData?.lastMessage?.message ?? '').isEmpty) ? 'Photo' : widget.conversationData?.lastMessage?.message ?? '';
      }
      if (firstAttachment.type == ConversationMessageAttachmentType.audio.name) {
        attachmentIcon = Icons.mic;
        lastMessage = ((widget.conversationData?.lastMessage?.message ?? '').isEmpty) ? 'Audio' : widget.conversationData?.lastMessage?.message ?? '';
      }
      if (firstAttachment.type == ConversationMessageAttachmentType.video.name) {
        attachmentIcon = Icons.videocam_rounded;
        lastMessage = ((widget.conversationData?.lastMessage?.message ?? '').isEmpty) ? 'Video' : widget.conversationData?.lastMessage?.message ?? '';
      } else {
        attachmentIcon = Icons.insert_drive_file_rounded;
        lastMessage =
            ((widget.conversationData?.lastMessage?.message ?? '').isEmpty) ? 'Attachment' : widget.conversationData?.lastMessage?.message ?? '';
      }
    } else {
      lastMessage = widget.conversationData?.lastMessage?.message ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listenWhen: (previous, current) {
        final oldConversation = previous.conversationsList?.firstWhere(
          (c) => c.id == widget.conversationData?.id,
          orElse: () => ConversationData(),
        );
        final newConversation = current.conversationsList?.firstWhere(
          (c) => c.id == widget.conversationData?.id,
          orElse: () => ConversationData(),
        );
        return oldConversation != newConversation;
      },
      listener: (context, state) {
        final updatedConversation = state.conversationsList?.firstWhere(
          (c) => c.id == widget.conversationData?.id,
          orElse: () => ConversationData(),
        );
        if (updatedConversation != null) {
          setState(() {
            widget.conversationData?.lastMessage = updatedConversation.lastMessage;
            getLastMessage();
          });
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              RoundProfileAvatar(
                radius: 25,
                userId: '',
                imageUrl: widget.conversationData?.members?[0].userData?.profile?.profilePicture ?? '',
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: BlocBuilder<ConversationBloc, ConversationState>(
                  buildWhen: (previous, current) => previous.onlineUserIds != current.onlineUserIds,
                  builder: (context, state) {
                    final bool isOnline = (state.onlineUserIds ?? []).contains(widget.conversationData?.members?[0].userId);
                    if (!isOnline) {
                      return SizedBox.shrink();
                    }
                    return Container(
                      height: 14,
                      width: 14,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        widget.conversationData?.title ?? widget.conversationData?.members?[0].userData?.fullName ?? '',
                        fontSize: 16,
                      ),
                    ),
                    CustomText(
                      widget.conversationData?.lastMessage?.updatedAt == null
                          ? ''
                          : TimeFormatter.formatTimeDifference(
                              DateTime.parse('${widget.conversationData?.lastMessage?.updatedAt}'.replaceAll('Z', ''))),
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (attachmentIcon != null)
                            Icon(
                              attachmentIcon,
                              size: 16,
                              color: Colors.grey,
                            ),
                          if (attachmentIcon != null) const SizedBox(width: 5),
                          Expanded(
                            child: CustomText(
                              "$lastMessage",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              color: widget.conversationData?.unreadCount != 0 ? Colors.black54 : Colors.grey,
                              fontSize: 12,
                              fontWeight: widget.conversationData?.unreadCount != 0 ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.conversationData?.unreadCount != 0) ...[
                      const SizedBox(width: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: CustomText(
                          "${widget.conversationData?.unreadCount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeFormatter {
  static String formatTimeDifference(DateTime updatedTime, {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final difference = now.difference(updatedTime);

    if (difference.inSeconds < 10) {
      return "just now";
    } else if (difference.inSeconds < 60) {
      final seconds = difference.inSeconds;
      return "$seconds ${seconds == 1 ? 'sec' : 'secs'} ago";
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return "$minutes ${minutes == 1 ? 'min' : 'mins'} ago";
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return "$hours ${hours == 1 ? 'hour' : 'hours'} ago";
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return "$days ${days == 1 ? 'day' : 'days'} ago";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks ${weeks == 1 ? 'week' : 'weeks'} ago";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "$months ${months == 1 ? 'month' : 'months'} ago";
    } else {
      final hour = updatedTime.hour % 12 == 0 ? 12 : updatedTime.hour % 12;
      final minute = updatedTime.minute.toString().padLeft(2, '0');
      final period = updatedTime.hour < 12 ? "AM" : "PM";
      return "$hour:$minute $period";
    }
  }
}
