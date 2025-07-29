import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/network/repository.dart';
import 'package:pictora/utils/constants/enums.dart';
import 'package:pictora/utils/services/custom_logger.dart';

import '../../../utils/helper/helper_function.dart';
import '../../../utils/helper/theme_helper.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final Repository repository;
  PostBloc(this.repository) : super(PostState()) {
    on<CreatePostEvent>(_createPost);
  }

  Future<void> _createPost(
      CreatePostEvent event, Emitter<PostState> emit) async {
    try {
      Map<String, dynamic> fields = {
        "caption": event.caption,
      };
      Map<String, dynamic> fileFields = {
        "media": event.mediaData,
      };

      if ((event.thumbnailData ?? []).isNotEmpty) {
        fileFields["thumbnails"] = event.thumbnailData;
      }

      logDebug(message: "Data-->>, $fileFields $fields");

      final data =
          await repository.createPost(fields: fields, fileFields: fileFields);

      logDebug(message: data.toString());
    } catch (error, stackTrace) {
      emit(state.copyWith(createPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
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
}
