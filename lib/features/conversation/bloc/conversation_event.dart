part of 'conversation_bloc.dart';

class ConversationEvent {}

class GetConversationsEvent extends ConversationEvent {}

class UpdateUserOnlineDataEvent extends ConversationEvent {
  final List<String> data;
  UpdateUserOnlineDataEvent({required this.data});
}

class GetConversationMessagesEvent extends ConversationEvent {
  final Map<String, dynamic> body;
  GetConversationMessagesEvent({required this.body});
}

class LoadMoreConversationMessagesEvent extends ConversationEvent {
  final Map<String, dynamic> body;
  LoadMoreConversationMessagesEvent({required this.body});
}

class CreateMessageEvent extends ConversationEvent {
  final String? message;
  final String conversationId;
  final String? replyToMessageId;
  final String? link;
  final String? postId;
  final List<File>? mediaData;
  final List<File>? thumbnailData;
  final User? senderData;

  CreateMessageEvent({
    required this.conversationId,
    this.message,
    this.mediaData,
    this.thumbnailData,
    this.postId,
    this.replyToMessageId,
    this.link,
    this.senderData,
  });
}

class GetUsersListEvent extends ConversationEvent {}
