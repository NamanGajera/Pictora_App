// Flutter
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Third-party
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

// Project
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../conversation.dart';

class MessagesView extends StatefulWidget {
  final ConversationData? conversationData;
  const MessagesView({super.key, required this.conversationData});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, List<ConversationMessage?>> _groupedMessages = {};
  List<String> _dateKeys = [];
  final _messageCache = <String, Widget>{};
  final _headerCache = <String, Widget>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() {
    final state = conversationBloc.state;
    if (state.isLoadingMoreMessages || !state.hasMoreMessages) return;

    conversationBloc.add(LoadMoreConversationMessagesEvent(body: {
      "conversationId": widget.conversationData?.id,
      "skip": state.conversationMessages[widget.conversationData?.id ?? widget.conversationData?.members?[0].userId]?.length ?? 0,
      "take": 40,
    }));
  }

  Map<String, List<ConversationMessage?>> _groupMessagesByDate(List<ConversationMessage?> messages) {
    final groupedMessages = <String, List<ConversationMessage?>>{};

    messages = List<ConversationMessage?>.from(messages)..sort((a, b) => (a?.createdAt ?? '').compareTo(b?.createdAt ?? ''));

    for (final message in messages) {
      final dateKey = DateFormatter.formatDate(format: DateFormatter.dayMonthYear, dateInput: message?.createdAt ?? '') ?? '';

      groupedMessages.putIfAbsent(dateKey, () => []).add(message);
    }

    return groupedMessages;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      buildWhen: (previous, current) =>
          previous.conversationMessages != current.conversationMessages || previous.isLoadingMoreMessages != current.isLoadingMoreMessages,
      builder: (context, state) {
        final messages = state.conversationMessages[widget.conversationData?.id ?? widget.conversationData?.members?[0].userId] ?? [];

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        _groupedMessages.clear();
        _groupedMessages.addAll(_groupMessagesByDate(messages));
        _dateKeys = _groupedMessages.keys.toList();

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: _dateKeys.length + (state.isLoadingMoreMessages ? 1 : 0),
          itemBuilder: (context, groupIndex) {
            if (state.isLoadingMoreMessages && groupIndex == _dateKeys.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final reversedIndex = _dateKeys.length - 1 - groupIndex;
            final dateKey = _dateKeys[reversedIndex];
            final messagesForDate = _groupedMessages[dateKey]!;

            return StickyHeader(
              header: _buildCachedDateHeader(dateKey),
              content: Column(
                children: List.generate(messagesForDate.length, (index) {
                  final message = messagesForDate[index];
                  return _buildCachedMessageBubble(message, index);
                }),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildCachedDateHeader(String date) {
    return _headerCache.putIfAbsent(date, () => _buildDateHeader(date));
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
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

  Widget _buildCachedMessageBubble(ConversationMessage? message, int index) {
    final cacheKey = '${message?.id}_$index';
    return _messageCache.putIfAbsent(cacheKey, () => _buildMessageBubble(message));
  }

  Widget _buildMessageBubble(ConversationMessage? message) {
    final isMyMessage = message?.senderId == userId;
    final messageTime = DateFormatter.getTimeOnly(message?.createdAt ?? '');
    final attachmentLength = (message?.attachments ?? []).length;
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
                color: isMyMessage ? const Color(0xFF075E54) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMyMessage ? 18 : 4),
                  bottomRight: Radius.circular(isMyMessage ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMyMessage && message?.senderData?.fullName != null && (widget.conversationData?.members ?? []).length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: CustomText(
                        message?.senderData?.fullName ?? '',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF075E54),
                      ),
                    ),
                  (message?.attachments ?? []).isNotEmpty
                      ? Container(
                          height: attachmentLength <= 2 ? 180 : 220,
                          width: 230,
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(top: 15),
                          child: MessageAttachmentView(message: message),
                        )
                      : CustomText(
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
                        fontSize: 10,
                        color: isMyMessage ? Colors.white70 : Colors.grey[600],
                      ),
                      const SizedBox(width: 5),
                      if (isMyMessage)
                        Icon(
                          message?.messageStatus == MessageStatus.sending
                              ? Icons.access_time_rounded
                              : message?.messageStatus == MessageStatus.sent
                                  ? Icons.done
                                  : Icons.done_all,
                          size: 14,
                          color: (message?.messageStatus == MessageStatus.read) ? const Color(0xff4FC3F7) : Colors.grey[400],
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

  String _formatDateHeader(String date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      final messageDate = DateFormat(DateFormatter.dayMonthYear).parse(date);
      final messageDay = DateTime(messageDate.year, messageDate.month, messageDate.day);

      final difference = today.difference(messageDay).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return DateFormat('EEEE').format(messageDate);
      }
    } catch (e) {
      debugPrint('Date parsing error: $e');
    }

    return date;
  }
}

class MessageAttachmentView extends StatefulWidget {
  final ConversationMessage? message;
  const MessageAttachmentView({super.key, required this.message});

  @override
  State<MessageAttachmentView> createState() => _MessageAttachmentViewState();
}

class _MessageAttachmentViewState extends State<MessageAttachmentView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final attachments = widget.message?.attachments ?? [];
    final totalAttachments = attachments.length;
    final displayAttachments = totalAttachments > 5 ? attachments.sublist(0, 5) : attachments;
    final remainingCount = totalAttachments > 5 ? totalAttachments - 5 : 0;

    if (displayAttachments.length == 1) {
      final attachment = displayAttachments[0];
      final String displayUrl = (attachment.type == "video") ? (attachment.thumbnailUrl ?? '') : (attachment.url ?? '');

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: displayUrl,
                cacheKey: attachment.id,
                key: ValueKey(attachment.id),
                height: 220,
                width: 230,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9CA3AF)),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xffF3F4F6),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xff9CA3AF),
                    size: 32,
                  ),
                ),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: attachment.type == "video"
                        ? const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(displayAttachments.length, (index) {
        final attachment = displayAttachments[index];
        final isFifthImage = index == 4 && remainingCount > 0;

        final String displayUrl = (attachment.type == "video") ? (attachment.thumbnailUrl ?? '') : (attachment.url ?? '');

        final double dx = index.isOdd ? -40.0 : 40.0;
        final double dy = index * 20.0;
        final double rotation = index.isOdd ? -0.12 : 0.12;
        final Alignment pivot = index.isOdd ? Alignment.topLeft : Alignment.topRight;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.rotate(
            angle: rotation,
            alignment: pivot,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: displayUrl,
                    cacheKey: attachment.id,
                    key: ValueKey(attachment.id),
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff9CA3AF)),
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xffF3F4F6),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xff9CA3AF),
                        size: 32,
                      ),
                    ),
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: attachment.type == "video"
                            ? const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  if (isFifthImage)
                    Container(
                      color: Colors.black54,
                      height: 140,
                      width: 140,
                      alignment: Alignment.center,
                      child: CustomText(
                        '+$remainingCount',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
