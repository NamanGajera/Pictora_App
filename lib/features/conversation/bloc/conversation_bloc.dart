// Third-party
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import 'package:pictora/core/utils/constants/constants.dart';
import 'package:pictora/features/conversation/conversation.dart';
import '../../../core/utils/helper/helper.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository conversationRepository;

  ConversationBloc(this.conversationRepository) : super(ConversationState()) {
    on<GetConversationsEvent>(_getConversations);
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
