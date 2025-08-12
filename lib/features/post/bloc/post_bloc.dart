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

import '../../../utils/constants/bloc_instances.dart';
import '../../../utils/helper/helper_function.dart';
import '../../../utils/helper/theme_helper.dart';
import '../../home/screens/home_screen.dart';
import '../../profile/bloc/profile_bloc/profile_bloc.dart';
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
    on<LoadMorePostEvent>(_loadMorePost, transformer: droppable());
    on<LoadMoreMyPostEvent>(_loadMoreMyPost, transformer: droppable());
    on<LoadMoreOtherUserPostEvent>(_loadMoreOtherUserPost, transformer: droppable());
    on<GetPostCommentDataEvent>(_getPostComment, transformer: droppable());
    on<CreateCommentEvent>(_createComment, transformer: droppable());
    on<GetCommentRepliesEvent>(_getReplies, transformer: droppable());
    on<ClearRepliesData>(_clearRepliesData, transformer: droppable());
    on<DeleteCommentEvent>(_deleteComment, transformer: droppable());
    on<ToggleCommentLikeEvent>(_toggleCommentLike, transformer: sequential());
    on<TogglePostLikeEvent>(_togglePostLike, transformer: sequential());
    on<TogglePostSaveEvent>(_togglePostSave, transformer: sequential());
    on<DeletePostEvent>(_deletePost, transformer: droppable());
    on<ArchivePostEvent>(_archivePost, transformer: droppable());
    on<GetLikedByUserEvent>(_getLikedByUser, transformer: droppable());
    on<GetMyPostEvent>(_getMyPost);
    on<GetOtherUserPostsEvent>(_getOtherUserPost);
    on<BlockScrollEvent>(_blockScroll);
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

      emit(state.copyWith(
        createPostApiStatus: ApiStatus.success,
        allPostData: [(data.data ?? PostData()), ...(state.allPostData ?? [])],
      ));
      ThemeHelper.showToastMessage(data.message ?? 'Post created');
      logDebug(message: data.toString());
    } catch (error, stackTrace) {
      emit(state.copyWith(createPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
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
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMorePost(LoadMorePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMorePost: true));
      final data = await repository.getAllPost(event.body);

      emit(state.copyWith(
        isLoadMorePost: false,
        allPostData: [...?state.allPostData, ...?data.data],
        hasMorePost: [...?state.allPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getAllPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreOtherUserPost(LoadMoreOtherUserPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreOtherUserPost: true));
      final data = await repository.getAllPost(event.body);

      emit(state.copyWith(
        isLoadMoreOtherUserPost: false,
        otherUserPostData: [...?state.otherUserPostData, ...?data.data],
        hasMoreOtherUserPost: [...?state.otherUserPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getAllPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreMyPost(LoadMoreMyPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreMyPost: true));
      final data = await repository.getAllPost(event.body);

      emit(state.copyWith(
        isLoadMoreMyPost: false,
        myPostData: [...?state.myPostData, ...?data.data],
        hasMoreMyPost: [...?state.myPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getAllPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getMyPost(GetMyPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getMyPostApiStatus: ApiStatus.loading));
      final data = await repository.getAllPost(event.body);

      emit(state.copyWith(
        getMyPostApiStatus: ApiStatus.success,
        myPostData: data.data,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getMyPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getOtherUserPost(GetOtherUserPostsEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getOtherUserPostApiStatus: ApiStatus.loading));
      final data = await repository.getAllPost(event.body);

      emit(state.copyWith(
        getOtherUserPostApiStatus: ApiStatus.success,
        otherUserPostData: data.data,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getOtherUserPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
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
      handleApiError(error, stackTrace, emit);
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
    } catch (error, stackTrace) {
      _updateComment(
        commentId: newComment.id ?? '',
        emit: emit,
        apiStatus: PostCommentApiStatus.failure,
      );
      _updatePostLists(emit: emit, postId: event.postId, updateCommentCount: false);

      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
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
      handleApiError(error, stackTrace, emit);
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
      handleApiError(error, stackTrace, emit);
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

      final CommentData comment = (state.commentDataList ?? []).firstWhere((comment) => comment.id == event.commentId, orElse: () => CommentData());
      int repliesCount = 0;
      if (comment.parentCommentId == null) {
        repliesCount = comment.repliesCount ?? 0;
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
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _togglePostLike(TogglePostLikeEvent event, Emitter<PostState> emit) async {
    try {
      _updatePostLists(postId: event.postId, emit: emit, isLiked: event.isLike);
      await repository.togglePostLike({
        "postId": event.postId,
        "isLike": event.isLike,
      });
    } catch (error, stackTrace) {
      _updatePostLists(postId: event.postId, emit: emit, isLiked: !event.isLike);
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _togglePostSave(TogglePostSaveEvent event, Emitter<PostState> emit) async {
    try {
      _updatePostLists(postId: event.postId, emit: emit, isSaved: event.isSave);
      await repository.togglePostSave({
        "postId": event.postId,
        "isSave": event.isSave,
      });
    } catch (error, stackTrace) {
      _updatePostLists(postId: event.postId, emit: emit, isSaved: !event.isSave);
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _deletePost(DeletePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(deletePostApiStatus: ApiStatus.loading));

      final data = await repository.deletePost(event.postId);
      ThemeHelper.showToastMessage(data.message ?? 'Post deleted');
      _updatePostLists(postId: event.postId, emit: emit, isDelete: true);
      emit(state.copyWith(deletePostApiStatus: ApiStatus.success));
      profileBloc.add(ModifyUserCountEvent(postsCount: -1));
      appRouter.pop();
    } catch (error, stackTrace) {
      emit(state.copyWith(deletePostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _archivePost(ArchivePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(archivePostApiStatus: ApiStatus.loading));

      final data = await repository.toggleArchivePost({
        "postId": event.postId,
        "isArchive": event.isArchive,
      });
      ThemeHelper.showToastMessage(data.message ?? 'Post archived');
      _updatePostLists(postId: event.postId, emit: emit, isDelete: event.isArchive);
      emit(state.copyWith(archivePostApiStatus: ApiStatus.success));
      appRouter.pop();
    } catch (error, stackTrace) {
      emit(state.copyWith(archivePostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getLikedByUser(GetLikedByUserEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(likeByUserApiStatus: ApiStatus.loading));
      final data = await repository.getLikedByUser(
        postId: event.postId,
        body: {
          "skip": 0,
          "take": 25,
        },
      );
      emit(state.copyWith(
        likeByUserApiStatus: ApiStatus.success,
        likedByUserData: data.data,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(likeByUserApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  void _blockScroll(BlockScrollEvent event, Emitter<PostState> emit) {
    emit(state.copyWith(isBlockScroll: event.isBlockScroll));
    logDebug(message: "Block scroll status: ${event.isBlockScroll}");
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
    bool? isLiked,
    bool? isSaved,
    bool? isDelete,
  }) {
    emit(state.copyWith(
      allPostData: _updatePostData(
        postList: state.allPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
      ),
      myPostData: _updatePostData(
        postList: state.myPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
      ),
      otherUserPostData: _updatePostData(
        postList: state.otherUserPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
      ),
    ));
  }

  List<PostData> _updatePostData({
    required List<PostData> postList,
    required String postId,
    bool? updateCommentCount,
    int? repliesCount,
    bool? isLiked,
    bool? isSaved,
    bool? isDelete,
  }) {
    final List<PostData> updatedList = postList.where((post) {
      if (post.id == postId && isDelete == true) {
        return false;
      }
      return true;
    }).map((post) {
      if (post.id == postId) {
        int commentCount = post.commentCount ?? 0;
        int likeCount = post.likeCount ?? 0;
        int saveCount = post.saveCount ?? 0;
        return post.copyWith(
          commentCount: updateCommentCount != null
              ? (updateCommentCount ? commentCount + 1 + (repliesCount ?? 0) : math.max(0, (commentCount - (1 + (repliesCount ?? 0)))))
              : post.commentCount,
          isLiked: isLiked ?? post.isLiked,
          likeCount: isLiked != null
              ? isLiked
                  ? ++likeCount
                  : --likeCount
              : post.likeCount,
          isSaved: isSaved ?? post.isSaved,
          saveCount: isSaved != null
              ? isSaved
                  ? ++saveCount
                  : --saveCount
              : post.saveCount,
        );
      }
      return post;
    }).toList();
    return updatedList;
  }

  void handleApiError(dynamic error, dynamic stackTrace, Emitter<PostState> emit) {
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
