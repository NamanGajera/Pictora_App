part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  final ApiStatus getConversationsDataApiStatus;
  final List<ConversationData>? conversationsList;
  final String? errorMessage;
  final int? statusCode;

  const ConversationState({
    this.getConversationsDataApiStatus = ApiStatus.initial,
    this.conversationsList,
    this.errorMessage,
    this.statusCode,
  });

  ConversationState copyWith({
    ApiStatus? getConversationsDataApiStatus,
    List<ConversationData>? conversationsList,
    String? errorMessage,
    int? statusCode,
  }) {
    return ConversationState(
      getConversationsDataApiStatus: getConversationsDataApiStatus ?? this.getConversationsDataApiStatus,
      conversationsList: conversationsList ?? this.conversationsList,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        getConversationsDataApiStatus,
        conversationsList,
        errorMessage,
        statusCode,
      ];
}
