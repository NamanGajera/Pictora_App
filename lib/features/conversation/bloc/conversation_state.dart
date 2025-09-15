part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  final ApiStatus getConversationsDataApiStatus;
  final ApiStatus getConversationMessagesDataApiStatus;
  final List<ConversationData>? conversationsList;
  final List<ConversationMessage>? conversationMessages;
  final List<String>? onlineUserIds;
  final String? errorMessage;
  final int? statusCode;

  const ConversationState({
    this.getConversationsDataApiStatus = ApiStatus.initial,
    this.getConversationMessagesDataApiStatus = ApiStatus.initial,
    this.conversationsList,
    this.conversationMessages,
    this.onlineUserIds,
    this.errorMessage,
    this.statusCode,
  });

  ConversationState copyWith({
    ApiStatus? getConversationsDataApiStatus,
    ApiStatus? getConversationMessagesDataApiStatus,
    List<ConversationData>? conversationsList,
    List<ConversationMessage>? conversationMessages,
    List<String>? onlineUserIds,
    String? errorMessage,
    int? statusCode,
  }) {
    return ConversationState(
      getConversationsDataApiStatus: getConversationsDataApiStatus ?? this.getConversationsDataApiStatus,
      getConversationMessagesDataApiStatus: getConversationMessagesDataApiStatus ?? this.getConversationMessagesDataApiStatus,
      conversationsList: conversationsList ?? this.conversationsList,
      conversationMessages: conversationMessages ?? this.conversationMessages,
      onlineUserIds: onlineUserIds ?? this.onlineUserIds,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        getConversationsDataApiStatus,
        getConversationMessagesDataApiStatus,
        conversationMessages,
        conversationsList,
        onlineUserIds,
        errorMessage,
        statusCode,
      ];
}
