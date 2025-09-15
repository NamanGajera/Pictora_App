part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  final ApiStatus getConversationsDataApiStatus;
  final List<ConversationData>? conversationsList;
  final List<String>? onlineUserIds;
  final String? errorMessage;
  final int? statusCode;

  const ConversationState({
    this.getConversationsDataApiStatus = ApiStatus.initial,
    this.conversationsList,
    this.onlineUserIds,
    this.errorMessage,
    this.statusCode,
  });

  ConversationState copyWith({
    ApiStatus? getConversationsDataApiStatus,
    List<ConversationData>? conversationsList,
    List<String>? onlineUserIds,
    String? errorMessage,
    int? statusCode,
  }) {
    return ConversationState(
      getConversationsDataApiStatus: getConversationsDataApiStatus ?? this.getConversationsDataApiStatus,
      conversationsList: conversationsList ?? this.conversationsList,
      onlineUserIds: onlineUserIds ?? this.onlineUserIds,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        getConversationsDataApiStatus,
        conversationsList,
        onlineUserIds,
        errorMessage,
        statusCode,
      ];
}
