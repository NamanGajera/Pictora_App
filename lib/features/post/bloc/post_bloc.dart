// Dart SDK
import 'dart:io';
import 'dart:math' as math;

// Third-party
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Project
import '../repository/post_repository.dart';
import '../../home/home.dart';
import '../../../core/database/hive_model/post_model/post_mapper.dart';
import '../../../core/utils/model/user_model.dart';
import '../../../core/config/router.dart';
import '../../../core/config/router_name.dart';
import '../../../core/utils/services/service.dart';
import '../../../core/database/hive/hive_boxes.dart';
import '../../../core/database/hive/hive_service.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/helper/helper.dart';
import '../../../core/database/hive_model/post_model/post_hive_model.dart';
import '../../profile/bloc/profile_bloc/profile_bloc.dart';
import '../models/models.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  final Uuid uuid;
  PostBloc(this.postRepository)
      : uuid = const Uuid(),
        super(PostState()) {
    on<CreatePostEvent>(_createPost, transformer: droppable());
    on<GetAllPostEvent>(_getAllPost);
    on<LoadMorePostEvent>(_loadMorePost, transformer: droppable());
    on<LoadMoreMyPostEvent>(_loadMoreMyPost, transformer: droppable());
    on<LoadMoreOtherUserPostEvent>(_loadMoreOtherUserPost, transformer: droppable());
    on<GetLikedPostEvent>(_getLikedPost, transformer: droppable());
    on<LoadMoreLikedPostEvent>(_loadMoreLikedPost, transformer: droppable());
    on<GetSavedPostEvent>(_getSavedPost, transformer: droppable());
    on<LoadMoreSavedPostEvent>(_loadMoreSavedPost, transformer: droppable());
    on<GetArchivedPostEvent>(_getArchivedPost, transformer: droppable());
    on<LoadMoreArchivedPostEvent>(_loadMoreArchivedPost, transformer: droppable());
    on<GetPostCommentDataEvent>(_getPostComment, transformer: droppable());
    on<LoadMorePostCommentDataEvent>(_loadMoreComments, transformer: droppable());
    on<CreateCommentEvent>(_createComment, transformer: droppable());
    on<GetCommentRepliesEvent>(_getReplies, transformer: droppable());
    on<LoadMoreCommentRepliesEvent>(_loadMoreReplies, transformer: droppable());
    on<ClearRepliesData>(_clearRepliesData, transformer: droppable());
    on<DeleteCommentEvent>(_deleteComment, transformer: droppable());
    on<ToggleCommentLikeEvent>(_toggleCommentLike, transformer: sequential());
    on<TogglePostLikeEvent>(_togglePostLike, transformer: sequential());
    on<TogglePostSaveEvent>(_togglePostSave, transformer: sequential());
    on<DeletePostEvent>(_deletePost, transformer: droppable());
    on<ArchivePostEvent>(_archivePost, transformer: droppable());
    on<GetLikedByUserEvent>(_getLikedByUser, transformer: droppable());
    on<LoadMoreLikedByUserEvent>(_loadMoreLikedByUser, transformer: droppable());
    on<GetMyPostEvent>(_getMyPost);
    on<GetOtherUserPostsEvent>(_getOtherUserPost);
    on<BlockScrollEvent>(_blockScroll);
    on<PostEvent>((event, emit) {
      if (event is DeleteCommentEvent) {}
    });
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

      final data = await postRepository.createPost(fields: fields, fileFields: fileFields);

      emit(state.copyWith(
        createPostApiStatus: ApiStatus.success,
        allPostData: [(data.data ?? PostData()), ...(state.allPostData ?? [])],
        myPostData: [(data.data ?? PostData()), ...(state.allPostData ?? [])],
      ));
      profileBloc.add(ModifyUserCountEvent(postsCount: 1));
      ThemeHelper.showToastMessage(data.message ?? 'Post created');
      logDebug(message: data.toString());
    } catch (error, stackTrace) {
      emit(state.copyWith(createPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getAllPost(GetAllPostEvent event, Emitter<PostState> emit) async {
    final connectivityService = ConnectivityService();
    bool isOnline = await connectivityService.checkConnection();

    logDebug(message: "Online: $isOnline");
    emit(state.copyWith(getAllPostApiStatus: ApiStatus.loading));
    final cachedPost = await getCachedPosts();
    List<PostData> postData = cachedPost.map((h) => h.toEntity()).toList();
    // if (!isOnline) {
    emit(state.copyWith(
      getAllPostApiStatus: ApiStatus.success,
      allPostData: _removeArchivedPost(postData),
    ));
    // }
    try {
      // emit(state.copyWith(getAllPostApiStatus: ApiStatus.loading));
      final data = await postRepository.getAllPost(event.body);

      emit(state.copyWith(
        getAllPostApiStatus: ApiStatus.success,
        allPostData: _removeArchivedPost(data.data ?? []),
        hasMorePost: (data.data ?? []).length < (data.total ?? 0),
      ));
      if (isOnline) {
        clearCache();
      }
      final hivePosts = (data.data ?? []).map((p) => p.toHiveModel()).toList();
      await cachePosts(hivePosts);
    } catch (error, stackTrace) {
      emit(state.copyWith(
        getAllPostApiStatus: ApiStatus.failure,
        allPostData: _removeArchivedPost(postData),
      ));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMorePost(LoadMorePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMorePost: true));
      final data = await postRepository.getAllPost(event.body);

      emit(state.copyWith(
        isLoadMorePost: false,
        allPostData: _removeArchivedPost([...?state.allPostData, ...?data.data]),
        hasMorePost: [...?state.allPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMorePost: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getLikedPost(GetLikedPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getLikedPostApiStatus: ApiStatus.loading));
      final data = await postRepository.getLikedPost(event.body);

      emit(state.copyWith(
        getLikedPostApiStatus: ApiStatus.success,
        likedPostData: _removeArchivedPost(data.data ?? []),
        hasMoreLikedPost: (data.data ?? []).length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getLikedPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreLikedPost(LoadMoreLikedPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreLikedPost: true));
      final data = await postRepository.getLikedPost(event.body);

      emit(state.copyWith(
        isLoadMoreLikedPost: false,
        likedPostData: _removeArchivedPost([...?state.likedPostData, ...?data.data]),
        hasMoreLikedPost: [...?state.likedPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreLikedPost: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getSavedPost(GetSavedPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getSavedPostApiStatus: ApiStatus.loading));
      final data = await postRepository.getSavedPost(event.body);

      emit(state.copyWith(
        getSavedPostApiStatus: ApiStatus.success,
        savedPostData: _removeArchivedPost(data.data ?? []),
        hasMoreSavedPost: (data.data ?? []).length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getSavedPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreSavedPost(LoadMoreSavedPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreSavedPost: true));
      final data = await postRepository.getSavedPost(event.body);

      emit(state.copyWith(
        isLoadMoreSavedPost: false,
        savedPostData: _removeArchivedPost([...?state.savedPostData, ...?data.data]),
        hasMoreSavedPost: [...?state.savedPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreSavedPost: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getArchivedPost(GetArchivedPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getArchivedPostApiStatus: ApiStatus.loading));
      final data = await postRepository.getArchivedPost(event.body);

      emit(state.copyWith(
        getArchivedPostApiStatus: ApiStatus.success,
        archivedPostData: data.data ?? [],
        hasMoreArchivedPost: (data.data ?? []).length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getArchivedPostApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreArchivedPost(LoadMoreArchivedPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreArchivedPost: true));
      final data = await postRepository.getArchivedPost(event.body);

      emit(state.copyWith(
        isLoadMoreArchivedPost: false,
        archivedPostData: [...?state.archivedPostData, ...?data.data],
        hasMoreArchivedPost: [...?state.archivedPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreArchivedPost: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreOtherUserPost(LoadMoreOtherUserPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreOtherUserPost: true));
      final data = await postRepository.getAllPost(event.body);

      emit(state.copyWith(
        isLoadMoreOtherUserPost: false,
        otherUserPostData: _removeArchivedPost([...?state.otherUserPostData, ...?data.data]),
        hasMoreOtherUserPost: [...?state.otherUserPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreOtherUserPost: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreMyPost(LoadMoreMyPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreMyPost: true));
      final data = await postRepository.getAllPost(event.body);

      emit(state.copyWith(
        isLoadMoreMyPost: false,
        myPostData: _removeArchivedPost([...?state.myPostData, ...?data.data]),
        hasMoreMyPost: [...?state.myPostData, ...?data.data].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreMyPost: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getMyPost(GetMyPostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(getMyPostApiStatus: ApiStatus.loading));
      final data = await postRepository.getAllPost(event.body);
      emit(state.copyWith(
        getMyPostApiStatus: ApiStatus.success,
        myPostData: _removeArchivedPost(data.data ?? []),
        hasMoreMyPost: (data.data ?? []).length < (data.total ?? 0),
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
      final data = await postRepository.getAllPost(event.body);
      logDebug(message: "Get all post data OTHER:${(data.data ?? []).length} <<<< ${(data.total ?? 0)}");
      emit(state.copyWith(
        getOtherUserPostApiStatus: ApiStatus.success,
        otherUserPostData: _removeArchivedPost(data.data ?? []),
        hasMoreOtherUserPost: (data.data ?? []).length < (data.total ?? 0),
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
      final data = await postRepository.getPostComment({"postId": event.postId});

      emit(state.copyWith(
        getPostCommentListApiStatus: ApiStatus.success,
        commentDataList: data.data,
        hasMorePostComments: (data.data ?? []).length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getPostCommentListApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreComments(LoadMorePostCommentDataEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMorePostComments: true));
      final data = await postRepository.getPostComment(event.body);

      emit(state.copyWith(
        isLoadMorePostComments: false,
        commentDataList: [...(state.commentDataList ?? []), ...(data.data ?? [])],
        hasMorePostComments: [...(state.commentDataList ?? []), ...(data.data ?? [])].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMorePostComments: false));
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

      final data = await postRepository.createComment(body);
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
      // repliesIdData.addAll(state.showReplies ?? {});
      if (repliesIdData.containsKey(event.commentId)) {
        repliesIdData.remove(event.commentId);
      } else {
        repliesIdData[event.commentId] = true;
      }
      emit(state.copyWith(showReplies: repliesIdData));

      final data = await postRepository.getCommentReplies({
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
        hasMoreCommentReplies: (data.data ?? []).length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getRepliesApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreReplies(LoadMoreCommentRepliesEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreReplies: true));
      final data = await postRepository.getCommentReplies({
        "skip": event.skip,
        "take": event.take,
        "commentId": event.commentId,
      });

      final CommentData comment = (state.commentDataList ?? []).firstWhere(
        (comment) => comment.id == event.commentId,
        orElse: () => CommentData(),
      );

      final List<CommentData> updatedRepliesList = [...(comment.repliesData ?? []), ...(data.data ?? [])];

      final List<CommentData> updatedCommentList = (state.commentDataList ?? []).map((comment) {
        if (comment.id == event.commentId) {
          return comment.copyWith(repliesData: updatedRepliesList);
        }
        return comment;
      }).toList();

      emit(state.copyWith(
        isLoadMoreReplies: false,
        commentDataList: updatedCommentList,
        hasMoreCommentReplies: updatedRepliesList.length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreReplies: false));
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
      await postRepository.toggleCommentLike({
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

      final data = await postRepository.deleteComment(event.commentId);

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
      await postRepository.togglePostLike({
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
      await postRepository.togglePostSave({
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

      final data = await postRepository.deletePost(event.postId);
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

      final data = await postRepository.toggleArchivePost({
        "postId": event.postId,
        "isArchive": event.isArchive,
      });
      ThemeHelper.showToastMessage(data.message ?? 'Post archived');
      _updatePostLists(postId: event.postId, emit: emit, isArchived: event.isArchive);
      emit(state.copyWith(archivePostApiStatus: ApiStatus.success));
      appRouter.pop();
    } catch (error, stackTrace) {
      emit(state.copyWith(archivePostApiStatus: ApiStatus.failure));
      _updatePostLists(postId: event.postId, emit: emit, isArchived: !event.isArchive);
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getLikedByUser(GetLikedByUserEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(likeByUserApiStatus: ApiStatus.loading));
      final data = await postRepository.getLikedByUser(
        postId: event.postId,
        body: {
          "skip": 0,
          "take": 25,
        },
      );
      emit(state.copyWith(
        likeByUserApiStatus: ApiStatus.success,
        likedByUserData: data.data,
        hasMoreLikedByUser: (data.data ?? []).length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(likeByUserApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreLikedByUser(LoadMoreLikedByUserEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreLikedByUser: true));
      final data = await postRepository.getLikedByUser(
        postId: event.postId,
        body: event.body,
      );
      emit(state.copyWith(
        isLoadMoreLikedByUser: false,
        likedByUserData: [...(state.likedByUserData ?? []), ...(data.data ?? [])],
        hasMoreLikedByUser: [...(state.likedByUserData ?? []), ...(data.data ?? [])].length < (data.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreLikedByUser: false));
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
    bool? isArchived,
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
        isArchived: isArchived,
      ),
      myPostData: _updatePostData(
        postList: state.myPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
        isArchived: isArchived,
      ),
      otherUserPostData: _updatePostData(
        postList: state.otherUserPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
        isArchived: isArchived,
      ),
      likedPostData: _updatePostData(
        postList: state.likedPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
        isArchived: isArchived,
      ),
      savedPostData: _updatePostData(
        postList: state.savedPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
        isArchived: isArchived,
      ),
      archivedPostData: _updatePostData(
        postList: state.archivedPostData ?? [],
        postId: postId,
        updateCommentCount: updateCommentCount,
        repliesCount: repliesCount,
        isLiked: isLiked,
        isSaved: isSaved,
        isDelete: isDelete,
        isArchived: isArchived,
        isArchivedPostList: true,
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
    bool? isArchived,
    bool? isArchivedPostList,
  }) {
    final List<PostData> updatedList = postList.where((post) {
      if (post.id == postId && isDelete == true) {
        return false;
      }
      return true;
    }).map((post) {
      if (post.id == postId) {
        logInfo(message: "isArchivedisArchivedisArchived==$isArchived");
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
          isArchived: isArchived ?? post.isArchived,
        );
      }
      return post;
    }).toList();
    return (isArchivedPostList ?? false)
        ? updatedList.where((post) => post.isArchived == true).toList()
        : updatedList.where((post) => post.isArchived != true).toList();
  }

  List<PostData> _removeArchivedPost(List<PostData> postList) {
    return postList.where((post) => post.isArchived != true).toList();
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

  Future<void> cachePosts(List<PostHiveModel> posts) async {
    final box = await HiveService.openBox<PostHiveModel>(HiveBoxes.posts);
    await box.clear();
    await box.addAll(posts);
  }

  Future<List<PostHiveModel>> getCachedPosts() async {
    final box = await HiveService.openBox<PostHiveModel>(HiveBoxes.posts);
    return box.values.toList();
  }

  Future<void> clearCache() async {
    await HiveService.clearBox<PostHiveModel>(HiveBoxes.posts);
  }
}
