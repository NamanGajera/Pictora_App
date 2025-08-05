import 'dart:io';
import 'dart:math' as math;
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
    on<ClearRepliesData>(_clearRepliesData, transformer: droppable());
    on<ToggleCommentLikeEvent>(_toggleCommentLike, transformer: sequential());
    on<DeleteCommentEvent>(_deleteComment, transformer: droppable());
    on<PinCommentEvent>(_pinComment, transformer: droppable());
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
      final List<CommentData> updatedList = event.commentParentId != null
          ? (state.commentDataList ?? []).map((item) {
              if (item.id == event.commentParentId) {
                return item.copyWith(
                  repliesData: [
                    newComment,
                    ...(item.repliesData ?? []),
                  ],
                );
              }
              return item;
            }).toList()
          : [newComment, ...(state.commentDataList ?? [])];

      emit(state.copyWith(commentDataList: updatedList));

      Map<String, dynamic> body = {
        "postId": event.postId,
        "comment": event.comment,
      };

      if (event.commentParentId != null) {
        body['parentCommentId'] = event.commentParentId;
      }

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
      final Map<String, bool> repliesIdData = {};
      if (repliesIdData.containsKey(event.commentId)) {
        repliesIdData.remove(event.commentId);
      } else {
        repliesIdData[event.commentId] = true;
      }
      emit(state.copyWith(showReplies: repliesIdData));

      add(GetCommentRepliesEvent(commentId: event.commentId));
      final data = await repository.getCommentReplies({
        "skip": event.skip,
        "take": event.take,
        "commentId": event.commentId,
      });

      final List<CommentData> updatedList = (state.commentDataList ?? []).map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(repliesData: data.data);
        }
        return comment;
      }).toList();

      if (repliesIdData.containsKey(event.commentId)) {
        repliesIdData[event.commentId] = false;
      }
      emit(state.copyWith(
        getRepliesApiStatus: ApiStatus.success,
        commentDataList: updatedList,
        showReplies: repliesIdData,
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

  Future<void> _clearRepliesData(ClearRepliesData event, Emitter<PostState> emit) async {
    logDebug(message: "Replies data clear-->>");
    emit(state.copyWith(showReplies: {}));
  }

  Future<void> _toggleCommentLike(ToggleCommentLikeEvent event, Emitter<PostState> emit) async {
    try {
      _updateComment(commentId: event.commentId, emit: emit, isLiked: event.isLike);
      await repository.toggleCommentLike({
        "commentId": event.commentId,
        "isLike": event.isLike,
      });
    } catch (error, stackTrace) {
      _updateComment(commentId: event.commentId, emit: emit, isLiked: !event.isLike);
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

  Future<void> _deleteComment(DeleteCommentEvent event, Emitter<PostState> emit) async {
    try {
      _updateComment(
        commentId: event.commentId,
        emit: emit,
        apiStatus: PostCommentApiStatus.deleting,
      );

      final data = await repository.deleteComment(event.commentId);

      final CommentData? comment = (state.commentDataList ?? []).firstWhere((comment) => comment.id == event.commentId, orElse: () => CommentData());
      int repliesCount = 0;
      if (comment?.parentCommentId == null) {
        repliesCount = comment?.repliesCount ?? 0;
      }
      _updateComment(
        commentId: event.commentId,
        emit: emit,
        isDelete: true,
      );
      _updatePostLists(
        emit: emit,
        postId: event.postId,
        updateCommentCount: false,
        repliesCount: repliesCount,
      );
      ThemeHelper.showToastMessage(data.message ?? 'Comment deleted');
    } catch (error, stackTrace) {
      _updateComment(
        commentId: event.commentId,
        emit: emit,
        apiStatus: PostCommentApiStatus.failedToDelete,
      );
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

  Future<void> _pinComment(PinCommentEvent event, Emitter<PostState> emit) async {
    try {
      final List<CommentData> commentList = state.commentDataList ?? [];
      final CommentData commentData = commentList.firstWhere((item) => item.id == event.commentId, orElse: () => CommentData());
      final commentIndex = commentList.indexWhere((item) => item.id == event.commentId);
      final data = await repository.pinComment(event.commentId, {});

      if (commentIndex != -1) {
        commentList.removeAt(commentIndex);
        commentList.insert(0, commentData);
      }

      emit(state.copyWith(commentDataList: commentList));
    } catch (error, stackTrace) {
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
    bool? isLiked,
    bool? isDelete,
  }) {
    final List<CommentData> updatedList = (state.commentDataList ?? []).where((item) {
      if (item.id == commentId && isDelete == true) {
        return false;
      }
      return true;
    }).map((item) {
      if (item.id == commentId) {
        int likeCount = item.likeCount ?? 0;
        return item.copyWith(
          id: commentData?.id,
          apiStatus: apiStatus,
          isLiked: isLiked ?? item.isLiked,
          likeCount: isLiked != null
              ? isLiked
                  ? ++likeCount
                  : --likeCount
              : item.likeCount,
        );
      }

      final updatedReplies = (item.repliesData ?? []).map((reply) {
        if (reply.id == commentId) {
          int likeCount = reply.likeCount ?? 0;
          return reply.copyWith(
            id: commentData?.id,
            apiStatus: apiStatus,
            isLiked: isLiked ?? item.isLiked,
            likeCount: isLiked != null
                ? isLiked
                    ? ++likeCount
                    : --likeCount
                : item.likeCount,
          );
        }
        return reply;
      }).toList();

      if (updatedReplies != item.repliesData) {
        return item.copyWith(repliesData: updatedReplies);
      }

      return item;
    }).toList();

    emit(state.copyWith(commentDataList: updatedList));
  }

  void _updatePostLists({
    required Emitter<PostState> emit,
    required String postId,
    bool? updateCommentCount,
    int? repliesCount,
  }) {
    emit(state.copyWith(
      allPostData: _updatePostData(
        postList: state.allPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
      ),
    ));
  }

  List<PostData> _updatePostData({
    required List<PostData> postList,
    required String postId,
    bool? updateCommentCount,
    int? repliesCount,
  }) {
    final List<PostData> updatedList = postList.map((post) {
      if (post.id == postId) {
        int commentCount = post.commentCount ?? 0;
        return post.copyWith(
          commentCount: updateCommentCount != null
              ? (updateCommentCount ? commentCount + 1 + (repliesCount ?? 0) : math.max(0, (commentCount - (1 + (repliesCount ?? 0)))))
              : post.commentCount,
        );
      }
      return post;
    }).toList();
    return updatedList;
  }
}
