part of 'conversation_bloc.dart';

class ConversationEvent {}

class GetConversationsEvent extends ConversationEvent {}

class UpdateUserOnlineDataEvent extends ConversationEvent{
  final List<String> data;
  UpdateUserOnlineDataEvent({required this.data});
}