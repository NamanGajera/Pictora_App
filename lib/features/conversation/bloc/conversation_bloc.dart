// Third-party
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Project
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/features/conversation/conversation.dart';
import '../../../core/utils/helper/helper.dart';
import '../../../core/utils/model/user_model.dart';
import '../../../core/utils/services/service.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository conversationRepository;
  final Uuid uuid;
  final Map<String, List<CreateMessageEvent>> _pendingMessages = {};
  final Map<String, bool> _isCreatingConversation = {};

  ConversationBloc(this.conversationRepository)
      : uuid = Uuid(),
        super(ConversationState()) {
    on<GetConversationsEvent>(_getConversations, transformer: droppable());
    on<UpdateUserOnlineDataEvent>(_updateUserOnlineIds, transformer: sequential());
    on<GetConversationMessagesEvent>(_getConversationMessages, transformer: droppable());
    on<LoadMoreConversationMessagesEvent>(_loadMoreConversationMessages, transformer: droppable());
    on<CreateMessageEvent>(_createMessage);
    on<GetUsersListEvent>(_getUserList, transformer: droppable());
    on<CreateConversationEvent>(_createConversation, transformer: droppable());

    conversationSocketListen();
  }

  Future<void> _getConversations(GetConversationsEvent event, Emitter<ConversationState> emit) async {
    try {
      emit(state.copyWith(getConversationsDataApiStatus: ApiStatus.loading));

      final data = await conversationRepository.getConversationsData();
      emit(state.copyWith(
        getConversationsDataApiStatus: ApiStatus.success,
        conversationsList: data.data ?? [],
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getConversationsDataApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getConversationMessages(GetConversationMessagesEvent event, Emitter<ConversationState> emit) async {
    try {
      emit(state.copyWith(getConversationMessagesDataApiStatus: ApiStatus.loading));

      final data = await conversationRepository.getConversationMessagesData(postBody: event.body);

      final conversation = state.conversationsList?.firstWhere((con) => con.id == event.body["conversationId"], orElse: () => ConversationData());
      final lastReadMessageId = conversation?.members?[0].lastReadMessageId;
      final lastMessageIndex = data.data?.indexWhere((msg) => msg.id == lastReadMessageId) ?? -1;

      if (lastMessageIndex != -1) {
        for (int i = lastMessageIndex; i < (data.data ?? []).length; i++) {
          data.data?[i].messageStatus = MessageStatus.read;
        }
      }

      emit(state.copyWith(
        getConversationMessagesDataApiStatus: ApiStatus.success,
        conversationMessages: data.data ?? [],
        hasMoreMessages: (data.data ?? []).length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getConversationMessagesDataApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreConversationMessages(LoadMoreConversationMessagesEvent event, Emitter<ConversationState> emit) async {
    try {
      emit(state.copyWith(isLoadingMoreMessages: true));

      await Future.delayed(Duration(milliseconds: 500));
      final data = await conversationRepository.getConversationMessagesData(postBody: event.body);
      emit(state.copyWith(
        isLoadingMoreMessages: false,
        conversationMessages: [...?state.conversationMessages, ...?data.data],
        hasMoreMessages: [...?state.conversationMessages, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadingMoreMessages: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _createMessage(CreateMessageEvent event, Emitter<ConversationState> emit) async {
    final tempId = uuid.v4();

    // Optimistic UI update
    final newMessage = ConversationMessage(
      id: tempId,
      conversationId: event.conversationId,
      senderId: userId,
      message: event.message,
      replyToMessageId: event.replyToMessageId,
      postId: event.postId,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      messageStatus: MessageStatus.sending,
      senderData: event.senderData,
      attachments: [],
    );

    emit(state.copyWith(
      conversationMessages: [newMessage, ...?state.conversationMessages],
    ));

    try {
      String? conversationId = event.conversationId;

      // If conversationId is missing -> queue
      if (conversationId == null) {
        final receiverId = event.receiverId!;
        _pendingMessages.putIfAbsent(receiverId, () => []);
        _pendingMessages[receiverId]!.add(event);

        if (_isCreatingConversation[receiverId] == true) {
          // Already creating -> just wait, queue will flush later
          return;
        }

        _isCreatingConversation[receiverId] = true;

        // Create conversation only once
        final conversationData = await createConversation(CreateConversationEvent(
          conversationType: ConversationType.private,
          userId: receiverId,
        ));

        if (conversationData == null) {
          // Fail all pending messages for this receiver
          for (var pending in _pendingMessages[receiverId] ?? []) {
            _updateMessages(
              tempId: tempId,
              messageStatus: MessageStatus.failed,
              emit: emit,
            );
          }
          _pendingMessages.remove(receiverId);
          _isCreatingConversation[receiverId] = false;
          return;
        }

        // Add to conversation list
        emit(state.copyWith(
          conversationsList: [conversationData, ...?state.conversationsList],
        ));

        conversationId = conversationData.id;

        // Flush all pending messages
        final queued = List<CreateMessageEvent>.from(_pendingMessages[receiverId]!);
        _pendingMessages.remove(receiverId);
        _isCreatingConversation[receiverId] = false;

        for (var pending in queued) {
          await _sendMessage(
            pending,
            conversationId: conversationId,
            emit: emit,
          );
        }
        return; // already handled sending
      }

      // Conversation exists -> send immediately
      await _sendMessage(event, conversationId: conversationId, emit: emit);
    } catch (error, stackTrace) {
      if (event.conversationId != null) {
        _updateMessages(tempId: tempId, messageStatus: MessageStatus.failed, emit: emit);
      }
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _sendMessage(
    CreateMessageEvent event, {
    required String? conversationId,
    required Emitter<ConversationState> emit,
  }) async {
    final tempId = uuid.v4();

    try {
      final message = await conversationRepository.createMessage(
        fields: {
          "conversationId": conversationId,
          if (event.message != null) "message": event.message,
          if (event.postId != null) "postId": event.postId,
          if (event.replyToMessageId != null) "replyToMessageId": event.replyToMessageId,
          if (event.link != null) "link": event.link,
        },
        fileFields: {
          if (event.mediaData != null && event.mediaData!.isNotEmpty) "media": event.mediaData!,
          if (event.thumbnailData != null && event.thumbnailData!.isNotEmpty) "thumbnails": event.thumbnailData!,
        },
      );

      _updateMessages(tempId: tempId, messageStatus: MessageStatus.sent, conversationMessage: message, emit: emit);
    } catch (error, stackTrace) {
      _updateMessages(tempId: tempId, messageStatus: MessageStatus.failed, emit: emit);
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _createConversation(CreateConversationEvent event, Emitter<ConversationState> emit) async {
    try {
      final conversation = await createConversation(event);
      emit(state.copyWith(conversationsList: [conversation ?? ConversationData(), ...?state.conversationsList]));
    } catch (error, stackTrace) {
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<ConversationData?> createConversation(CreateConversationEvent event) async {
    try {
      Map<String, dynamic> fields = {
        "type": event.conversationType.name,
      };

      Map<String, dynamic> fileFields = {};

      if ((event.members ?? []).isNotEmpty) {
        fields["members"] = event.members;
      }

      if ((event.title ?? '').isNotEmpty) {
        fields["title"] = event.title;
      }

      if ((event.userId ?? '').isNotEmpty) {
        fields["userId"] = event.userId;
      }

      if ((event.groupImage ?? []).isNotEmpty) {
        fileFields["groupImage"] = event.groupImage;
      }

      final conversation = await conversationRepository.createConversation(fields: fields, fileFields: fileFields);

      return conversation;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _getUserList(GetUsersListEvent event, Emitter<ConversationState> emit) async {
    try {
      final data = await conversationRepository.getAllUserList({"isPrivate": false});
      emit(state.copyWith(usersList: data.data ?? []));
    } catch (error, stackTrace) {
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  void _updateMessages({String? tempId, MessageStatus? messageStatus, ConversationMessage? conversationMessage, Emitter<ConversationState>? emit}) {
    if (emit == null) return;

    final updatedMessages = state.conversationMessages?.map((msg) {
      if (tempId != null && msg.id == tempId) {
        return msg.copyWith(
          messageStatus: messageStatus,
          id: conversationMessage?.id,
        );
      }
      return msg;
    }).toList();

    final updatedConversation = (state.conversationsList ?? []).map(
      (con) {
        if (con.id == conversationMessage?.conversationId) {
          return con.copyWith(lastMessage: conversationMessage);
        }
        return con;
      },
    ).toList();

    emit(state.copyWith(conversationMessages: updatedMessages, conversationsList: updatedConversation));
  }

  void _updateUserOnlineIds(UpdateUserOnlineDataEvent event, Emitter<ConversationState> emit) {
    logDebug(message: "User online list updated ${event.data}");
    emit(state.copyWith(onlineUserIds: event.data));
  }

  void conversationSocketListen() {
    SocketService().eventManager.eventStream('user_presence').listen((data) {
      logInfo(message: "User Presence Listen $data", tag: "Socket Log");
      List<String> onlineUserIds = List.from(state.onlineUserIds ?? []);

      if (data["status"] == false) {
        onlineUserIds.removeWhere((id) => id == data["userId"]);
      } else if (data["status"] == true) {
        onlineUserIds.add(data["userId"]);
      }

      add(UpdateUserOnlineDataEvent(
        data: onlineUserIds,
      ));
    });

    SocketService().eventManager.eventStream('online_users').listen((data) {
      add(UpdateUserOnlineDataEvent(
        data: List<String>.from(data ?? []),
      ));
    });
  }

  void handleApiError(dynamic error, dynamic stackTrace, Emitter<ConversationState> emit) {
    handleError(
      error: error,
      stackTrace: stackTrace,
      emit: emit,
      stateCopyWith: (statusCode, errorMessage) => state.copyWith(
        statusCode: statusCode,
        errorMessage: errorMessage,
      ),
    );
  }
}
