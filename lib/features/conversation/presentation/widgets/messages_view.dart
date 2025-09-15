import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/core/utils/widgets/custom_widget.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../../../core/utils/helper/helper.dart';
import '../../conversation.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, List<ConversationMessage?>> _groupedMessages = {};
  List<String> _dateKeys = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    }
  }

  Map<String, List<ConversationMessage?>> _groupMessagesByDate(List<ConversationMessage?> messages) {
    Map<String, List<ConversationMessage?>> groupedMessages = {};

    messages.sort((a, b) {
      final aDate = a?.createdAt ?? '';
      final bDate = b?.createdAt ?? '';
      return aDate.compareTo(bDate);
    });

    for (var message in messages) {
      String dateKey = DateFormatter.formatDate(format: DateFormatter.dayMonthYear, dateInput: message?.createdAt ?? '') ?? '';

      if (groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey]!.add(message);
      } else {
        groupedMessages[dateKey] = [message];
      }
    }

    return groupedMessages;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      buildWhen: (previous, current) => previous.conversationMessages != current.conversationMessages,
      builder: (context, state) {
        final messages = state.conversationMessages ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                CustomText(
                  "No Messages",
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                CustomText(
                  "Start a conversation",
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ],
            ),
          );
        }

        // Group messages by date
        _groupedMessages.clear();
        _groupedMessages.addAll(_groupMessagesByDate(messages.toList()));
        _dateKeys = _groupedMessages.keys.toList();

        // Scroll to bottom after building
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // This makes the list start from the bottom
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: _dateKeys.length,
          itemBuilder: (context, groupIndex) {
            // Since we're using reverse: true, we need to reverse the index
            final reversedIndex = _dateKeys.length - 1 - groupIndex;
            final dateKey = _dateKeys[reversedIndex];
            final messagesForDate = _groupedMessages[dateKey]!;

            return StickyHeader(
              header: _buildDateHeader(dateKey),
              content: Column(
                children: messagesForDate.map((message) {
                  return _buildMessageBubble(message);
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomText(
            _formatDateHeader(date),
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(String date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final messageDate = DateFormat(DateFormatter.dayMonthYear).parse(date);
    final messageDay = DateTime(messageDate.year, messageDate.month, messageDate.day);

    final difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(messageDate);
    } else {
      return date;
    }
  }

  Widget _buildMessageBubble(ConversationMessage? message) {
    final isMyMessage = message?.senderId == userId;
    final messageTime = DateFormatter.getTimeOnly(message?.createdAt ?? '');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: EdgeInsets.only(
                left: isMyMessage ? 40 : 0,
                right: isMyMessage ? 0 : 40,
                bottom: 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMyMessage
                    ? const Color(0xFF075E54) // WhatsApp green
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMyMessage ? 18 : 4),
                  bottomRight: Radius.circular(isMyMessage ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMyMessage && message?.senderData?.fullName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: CustomText(
                        message?.senderData?.fullName ?? '',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF075E54),
                      ),
                    ),
                  CustomText(
                    message?.message ?? 'Attachment',
                    fontSize: 16,
                    color: isMyMessage ? Colors.white : Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        messageTime ?? '',
                        fontSize: 11,
                        color: isMyMessage ? Colors.white70 : Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
