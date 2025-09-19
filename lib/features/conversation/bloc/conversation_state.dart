part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  final ApiStatus getConversationsDataApiStatus;
  final ApiStatus getConversationMessagesDataApiStatus;
  final List<ConversationData>? conversationsList;
  final Map<String, List<ConversationMessage>?> conversationMessages;
  final List<User>? usersList;
  final bool isLoadingMoreMessages;
  final bool hasMoreMessages;
  final List<String>? onlineUserIds;
  final Map<String, List<String>> conversationJoinedUserData;
  final String? errorMessage;
  final int? statusCode;

  const ConversationState({
    this.getConversationsDataApiStatus = ApiStatus.initial,
    this.getConversationMessagesDataApiStatus = ApiStatus.initial,
    this.conversationsList,
    this.conversationMessages = const {},
    this.usersList,
    this.isLoadingMoreMessages = false,
    this.hasMoreMessages = true,
    this.onlineUserIds,
    this.conversationJoinedUserData = const {},
    this.errorMessage,
    this.statusCode,
  });

  ConversationState copyWith({
    ApiStatus? getConversationsDataApiStatus,
    ApiStatus? getConversationMessagesDataApiStatus,
    List<ConversationData>? conversationsList,
    Map<String, List<ConversationMessage>?>? conversationMessages,
    List<String>? onlineUserIds,
    List<User>? usersList,
    bool? isLoadingMoreMessages,
    bool? hasMoreMessages,
    Map<String, List<String>>? conversationJoinedUserData,
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
      conversationJoinedUserData: conversationJoinedUserData ?? this.conversationJoinedUserData,
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
        conversationJoinedUserData,
        errorMessage,
        statusCode,
      ];
}
