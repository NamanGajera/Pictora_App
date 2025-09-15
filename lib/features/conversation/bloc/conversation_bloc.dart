// Third-party
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/features/conversation/conversation.dart';
import '../../../core/utils/helper/helper.dart';
import '../../../core/utils/services/service.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository conversationRepository;

  ConversationBloc(this.conversationRepository) : super(ConversationState()) {
    on<GetConversationsEvent>(_getConversations);
    on<UpdateUserOnlineDataEvent>(_updateUserOnlineIds);

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

  void _updateUserOnlineIds(UpdateUserOnlineDataEvent event, Emitter<ConversationState> emit){
    logDebug(message: "User online list updated ${event.data}");
    emit(state.copyWith(onlineUserIds: event.data));
  }

  void conversationSocketListen() {
    SocketService().eventManager.eventStream('user_presence').listen((data) {
      logInfo(message: "User Presence Listen $data", tag: "Socket Log");
      List<String> onlineUserIds = List.from(state.onlineUserIds ?? []);

      if(data["status"] == false){
        onlineUserIds.removeWhere((id)=> id == data["userId"]);
      }else if(data["status"] == true){
        onlineUserIds.add(data["userId"]);
      }

      add(UpdateUserOnlineDataEvent(
        data: onlineUserIds,
      ));
    });

    SocketService().eventManager.eventStream('online_users').listen((data){
      add(UpdateUserOnlineDataEvent(
        data: data,
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
