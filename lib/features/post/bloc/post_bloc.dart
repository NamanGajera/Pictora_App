import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/network/repository.dart';
import 'package:pictora/router/router.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/utils/constants/enums.dart';
import 'package:pictora/utils/services/custom_logger.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../utils/helper/helper_function.dart';
import '../../../utils/helper/theme_helper.dart';
import '../../home/screens/home_screen.dart';
import '../models/post_data.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final Repository repository;
  PostBloc(this.repository) : super(PostState()) {
    on<CreatePostEvent>(_createPost, transformer: droppable());
    on<GetAllPostEvent>(_getAllPost);
  }

  Future<void> _createPost(
      CreatePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(createPostApiStatus: ApiStatus.loading));
      appRouter.go(RouterName.home.path,
          extra: HomeScreenDataModel(fileImage: event.previewFile));

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
      emit(state.copyWith(createPostApiStatus: ApiStatus.success));
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

  Future<void> _getAllPost(
      GetAllPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getAllPostApiStatus: ApiStatus.loading));
      final data = await repository.getAllPost(event.body);

      emit(state.copyWith(
        getAllPostApiStatus: ApiStatus.success,
        allPostData: data.data,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getAllPostApiStatus: ApiStatus.failure));
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
