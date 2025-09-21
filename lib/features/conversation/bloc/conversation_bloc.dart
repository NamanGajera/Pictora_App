// Third-party
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Project
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/features/conversation/conversation.dart';
import 'package:uuid/uuid.dart';

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
    on<SocketNewMessageReceiveEvent>(_socketNewMessage, transformer: sequential());
    on<ConversationConnectionHandleEvent>(_conversationConnectionHandle, transformer: sequential());

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

      final updatedData = Map<String, List<ConversationMessage>?>.from(state.conversationMessages);

      updatedData[event.body["conversationId"]] = data.data ?? [];

      emit(state.copyWith(
        getConversationMessagesDataApiStatus: ApiStatus.success,
        conversationMessages: updatedData,
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

      final updatedData = Map<String, List<ConversationMessage>?>.from(state.conversationMessages);
      final existingMessages = updatedData[event.body["conversationId"]] ?? [];

      updatedData[event.body["conversationId"]] = [
        ...existingMessages,
        ...?data.data,
      ];
      emit(state.copyWith(
        isLoadingMoreMessages: false,
        conversationMessages: updatedData,
        hasMoreMessages: [...?state.conversationMessages["conversationId"], ...?data.data].length < (data.total ?? 0),
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

    final updatedData = Map<String, List<ConversationMessage>?>.from(state.conversationMessages);
    final existingMessages = updatedData[event.conversationId] ?? [];

    updatedData[event.conversationId ?? event.receiverId ?? ''] = [
      newMessage,
      ...existingMessages,
    ];
    emit(state.copyWith(
      conversationMessages: updatedData,
    ));

    try {
      String? conversationId = event.conversationId;

      // If conversationId is missing -> queue
      if (conversationId == null) {
        final receiverId = event.receiverId!;
        _pendingMessages.putIfAbsent(receiverId, () => []);
        _pendingMessages[receiverId]!.add(event);

        if (_isCreatingConversation[receiverId] == true) {
          return;
        }

        _isCreatingConversation[receiverId] = true;

        // Create conversation only once
        final conversationData = await createConversation(
          CreateConversationEvent(
            conversationType: ConversationType.private,
            userId: receiverId,
          ),
          emit,
        );

        if (conversationData == null) {
          for (var pending in _pendingMessages[receiverId] ?? []) {
            _updateMessages(
              tempId: tempId,
              messageStatus: MessageStatus.failed,
              conversationId: event.conversationId ?? event.receiverId,
              emit: emit,
            );
          }
          _pendingMessages.remove(receiverId);
          _isCreatingConversation[receiverId] = false;
          return;
        }

        conversationId = conversationData.id;

        // Flush all pending messages
        final queued = List<CreateMessageEvent>.from(_pendingMessages[receiverId]!);
        _pendingMessages.remove(receiverId);
        _isCreatingConversation[receiverId] = false;

        for (var pending in queued) {
          await _sendMessage(
            pending,
            conversationId: conversationId,
            receiverId: event.receiverId,
            emit: emit,
            tempId: tempId,
          );
        }
        return; // already handled sending
      }

      // Conversation exists -> send immediately
      await _sendMessage(event, conversationId: conversationId, emit: emit, tempId: tempId);
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
    String? receiverId,
    required Emitter<ConversationState> emit,
    required String? tempId,
  }) async {
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

      _updateMessages(tempId: tempId, conversationId: receiverId ?? conversationId, messageStatus: MessageStatus.sent, conversationMessage: message, emit: emit);
    } catch (error, stackTrace) {
      _updateMessages(tempId: tempId, conversationId: receiverId ?? conversationId, messageStatus: MessageStatus.failed, emit: emit);
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _createConversation(CreateConversationEvent event, Emitter<ConversationState> emit) async {
    try {
      await createConversation(event, emit);
    } catch (error, stackTrace) {
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<ConversationData?> createConversation(CreateConversationEvent event, Emitter<ConversationState> emit) async {
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
      emit(state.copyWith(conversationsList: [conversation, ...?state.conversationsList]));
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

  void _updateMessages({String? tempId, String? conversationId, MessageStatus? messageStatus, ConversationMessage? conversationMessage, Emitter<ConversationState>? emit}) {
    if (emit == null) return;

    final updatedMessages = (state.conversationMessages[conversationId] ?? []).map((msg) {
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

    final updatedData = Map<String, List<ConversationMessage>?>.from(state.conversationMessages);

    updatedData[conversationId ?? ''] = updatedMessages;

    emit(state.copyWith(conversationMessages: updatedData, conversationsList: updatedConversation));
  }

  void _updateUserOnlineIds(UpdateUserOnlineDataEvent event, Emitter<ConversationState> emit) {
    logDebug(message: "User online list updated ${event.data}");
    emit(state.copyWith(onlineUserIds: event.data));
  }

  void _socketNewMessage(SocketNewMessageReceiveEvent event, Emitter<ConversationState> emit) {
    logInfo(message: "${event.message.toJson()}", tag: "New Messages =====================>>");

    final updatedConversation = (state.conversationsList ?? []).map(
      (con) {
        if (con.id == event.message.conversationId) {
          final joinConversationUserIds = state.conversationJoinedUserData[event.message.conversationId];
          final bool isConversationJoined = (joinConversationUserIds ?? []).contains(userId);
          int unreadCount = isConversationJoined ? 0 : (con.unreadCount ?? 0) + 1;
          return con.copyWith(lastMessage: event.message, unreadCount: unreadCount);
        }
        return con;
      },
    ).toList();

    final updatedData = Map<String, List<ConversationMessage>?>.from(state.conversationMessages);
    final existingMessages = updatedData[event.message.conversationId] ?? [];

    updatedData[event.message.conversationId ?? ''] = [
      ...existingMessages,
      event.message,
    ];

    emit(state.copyWith(conversationMessages: updatedData, conversationsList: updatedConversation));
  }

  void _conversationConnectionHandle(ConversationConnectionHandleEvent event, Emitter<ConversationState> emit) {
    final updatedData = Map<String, List<String>>.from(state.conversationJoinedUserData);

    final userIds = List<String>.from(updatedData[event.conversationId] ?? []);

    if (userIds.contains(event.userId)) {
      userIds.removeWhere((id) => id == event.userId);
    } else {
      userIds.add(event.userId);
    }
    List<ConversationData> updatedConversation = List<ConversationData>.from(state.conversationsList ?? []);

    if (event.updateConversationData == true) {
      updatedConversation = (state.conversationsList ?? []).map((con) {
        if (con.id == event.conversationId) {
          final lastMessage = state.conversationMessages[event.conversationId]?[0];

          if (event.userId == userId) {
            return con.copyWith(
              unreadCount: 0,
            );
          } else {
            return con.copyWith(
              members: (con.members ?? []).map((mem) {
                return mem.copyWith(
                  lastReadMessageId: lastMessage?.id,
                );
              }).toList(),
            );
          }
        }
        return con;
      }).toList();
    }

    updatedData[event.conversationId] = userIds;

    final lastMessageIndex = state.conversationMessages[event.conversationId]?.indexWhere((msg) => msg.id == state.conversationMessages[event.conversationId]?[0].id) ?? -1;

    if (lastMessageIndex != -1) {
      for (int i = lastMessageIndex; i < (state.conversationMessages[event.conversationId] ?? []).length; i++) {
        state.conversationMessages[event.conversationId]?[i].messageStatus = MessageStatus.read;
      }
    }

    final updatedMessagesData = Map<String, List<ConversationMessage>?>.from(state.conversationMessages);

    updatedMessagesData[event.conversationId] = state.conversationMessages[event.conversationId] ?? [];

    emit(state.copyWith(
      conversationJoinedUserData: updatedData,
      conversationsList: updatedConversation,
      conversationMessages: updatedMessagesData,
    ));
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

    SocketService().eventManager.eventStream('new_message').listen((data) {
      final newMessage = ConversationMessage.fromJson(data["data"]);

      if (newMessage.senderId != userId) {
        add(SocketNewMessageReceiveEvent(message: newMessage));
      }
    });

    SocketService().eventManager.eventStream('conversation_joined').listen((data) {
      add(ConversationConnectionHandleEvent(
        conversationId: data["conversationId"],
        userId: data["userId"],
        updateConversationData: true,
      ));
    });

    SocketService().eventManager.eventStream('conversation_left').listen((data) {
      add(ConversationConnectionHandleEvent(
        conversationId: data["conversationId"],
        userId: data["userId"],
        updateConversationData: false,
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
