import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/model/user_model.dart';
import 'package:pictora/network/repository.dart';
import 'package:pictora/router/router.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/utils/constants/constants.dart';
import 'package:pictora/utils/constants/enums.dart';
import 'package:pictora/utils/services/custom_logger.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/helper/helper_function.dart';
import '../../../utils/helper/theme_helper.dart';
import '../../home/screens/home_screen.dart';
import '../models/post_comment_data_model.dart';
import '../models/post_data.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final Repository repository;
  final Uuid uuid;
  PostBloc(this.repository)
      : uuid = const Uuid(),
        super(PostState()) {
    on<CreatePostEvent>(_createPost, transformer: droppable());
    on<GetAllPostEvent>(_getAllPost);
    on<GetPostCommentDataEvent>(_getPostComment, transformer: droppable());
    on<CreateCommentEvent>(_createComment, transformer: droppable());
    on<GetCommentRepliesEvent>(_getReplies, transformer: droppable());
  }

  Future<void> _createPost(CreatePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(createPostApiStatus: ApiStatus.loading));
      appRouter.go(RouterName.home.path, extra: HomeScreenDataModel(fileImage: event.previewFile));

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

      final data = await repository.createPost(fields: fields, fileFields: fileFields);

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

  Future<void> _getAllPost(GetAllPostEvent event, Emitter<PostState> emit) async {
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

  Future<void> _getPostComment(GetPostCommentDataEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getPostCommentListApiStatus: ApiStatus.loading));
      final data = await repository.getPostComment({"postId": event.postId});

      emit(state.copyWith(
        getPostCommentListApiStatus: ApiStatus.success,
        commentDataList: data.data,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getPostCommentListApiStatus: ApiStatus.failure));
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

  Future<void> _createComment(CreateCommentEvent event, Emitter<PostState> emit) async {
    final tempId = uuid.v4();

    final newComment = CommentData(
      id: tempId,
      comment: event.comment,
      userId: event.userId,
      createdAt: DateTime.now().toString(),
      user: User(
        fullName: userFullName,
        userName: userName,
        profile: Profile(
          profilePicture: userProfilePic,
        ),
      ),
      apiStatus: PostCommentApiStatus.posting,
    );
    try {
      Map<String, dynamic> body = {
        "postId": event.postId,
        "comment": event.comment,
      };

      if (event.commentParentId != null) {
        body['parentCommentId'] = event.commentParentId;
      }

      final List<CommentData> updatedList = [newComment, ...(state.commentDataList ?? [])];

      emit(state.copyWith(commentDataList: updatedList));

      final data = await repository.createComment(body);
      _updateComment(
        commentId: newComment.id ?? '',
        emit: emit,
        apiStatus: PostCommentApiStatus.success,
        commentData: data,
      );
      _updatePostLists(emit: emit, postId: event.postId, updateCommentCount: true);
      ThemeHelper.showToastMessage("Comment add successfully");
    } catch (error, stackTrace) {
      _updateComment(
        commentId: newComment.id ?? '',
        emit: emit,
        apiStatus: PostCommentApiStatus.failure,
      );
      _updatePostLists(emit: emit, postId: event.postId, updateCommentCount: false);

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

  Future<void> _getReplies(GetCommentRepliesEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getRepliesApiStatus: ApiStatus.loading));
      final data = await repository.getPostComment({
        "skip": event.skip,
        "take": event.take,
        "commentId": event.commentId,
      });

      emit(state.copyWith(
        getRepliesApiStatus: ApiStatus.success,
        commentDataList: data.data,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getRepliesApiStatus: ApiStatus.failure));
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

  void _updateComment({
    required String commentId,
    PostCommentApiStatus apiStatus = PostCommentApiStatus.success,
    required Emitter<PostState> emit,
    CommentData? commentData,
  }) {
    final List<CommentData> updatedList = (state.commentDataList ?? []).map((item) {
      if (item.id == commentId) {
        return item.copyWith(
          id: commentData?.id,
          apiStatus: apiStatus,
        );
      }

      return item;
    }).toList();
    emit(state.copyWith(commentDataList: updatedList));
  }

  void _updatePostLists({
    required Emitter<PostState> emit,
    required String postId,
    bool? updateCommentCount,
  }) {
    emit(state.copyWith(
      allPostData: _updatePostData(
        postList: state.allPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
      ),
    ));
  }

  List<PostData> _updatePostData({
    required List<PostData> postList,
    required String postId,
    bool? updateCommentCount,
  }) {
    final List<PostData> updatedList = postList.map((post) {
      if (post.id == postId) {
        int commentCount = post.commentCount ?? 0;
        return post.copyWith(commentCount: updateCommentCount != null ? (updateCommentCount ? ++commentCount : --commentCount) : post.commentCount);
      }
      return post;
    }).toList();
    return updatedList;
  }
}
