part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  final ApiStatus getConversationsDataApiStatus;
  final ApiStatus getConversationMessagesDataApiStatus;
  final List<ConversationData>? conversationsList;
  final List<ConversationMessage>? conversationMessages;
  final List<User>? usersList;
  final bool isLoadingMoreMessages;
  final bool hasMoreMessages;
  final List<String>? onlineUserIds;
  final String? errorMessage;
  final int? statusCode;

  const ConversationState({
    this.getConversationsDataApiStatus = ApiStatus.initial,
    this.getConversationMessagesDataApiStatus = ApiStatus.initial,
    this.conversationsList,
    this.conversationMessages,
    this.usersList,
    this.isLoadingMoreMessages = false,
    this.hasMoreMessages = true,
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
    List<User>? usersList,
    bool? isLoadingMoreMessages,
    bool? hasMoreMessages,
    String? errorMessage,
    int? statusCode,
  }) {
    return ConversationState(
      getConversationsDataApiStatus: getConversationsDataApiStatus ?? this.getConversationsDataApiStatus,
      getConversationMessagesDataApiStatus: getConversationMessagesDataApiStatus ?? this.getConversationMessagesDataApiStatus,
      conversationsList: conversationsList ?? this.conversationsList,
      conversationMessages: conversationMessages ?? this.conversationMessages,
      onlineUserIds: onlineUserIds ?? this.onlineUserIds,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      usersList: usersList ?? this.usersList,
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
        isLoadingMoreMessages,
        hasMoreMessages,
        usersList,
        onlineUserIds,
        errorMessage,
        statusCode,
      ];
}
