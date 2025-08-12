part of 'post_bloc.dart';

class PostState extends Equatable {
  final ApiStatus createPostApiStatus;
  final ApiStatus getAllPostApiStatus;
  final ApiStatus getPostCommentListApiStatus;
  final ApiStatus getRepliesApiStatus;
  final ApiStatus deletePostApiStatus;
  final ApiStatus archivePostApiStatus;
  final ApiStatus likeByUserApiStatus;
  final ApiStatus getOtherUserPostApiStatus;
  final ApiStatus getMyPostApiStatus;
  final Map<String, bool>? showReplies;
  final List<PostData>? allPostData;
  final List<PostData>? otherUserPostData;
  final List<PostData>? myPostData;
  final List<User>? likedByUserData;
  final List<CommentData>? commentDataList;
  final bool isBlockScroll;
  final bool isLoadMorePost;
  final bool hasMorePost;
  final bool isLoadMoreMyPost;
  final bool hasMoreMyPost;
  final bool hasMoreOtherUserPost;
  final bool isLoadMoreOtherUserPost;
  final int? statusCode;
  final String? errorMessage;

  const PostState({
    this.createPostApiStatus = ApiStatus.initial,
    this.getAllPostApiStatus = ApiStatus.initial,
    this.getPostCommentListApiStatus = ApiStatus.initial,
    this.getRepliesApiStatus = ApiStatus.initial,
    this.deletePostApiStatus = ApiStatus.initial,
    this.archivePostApiStatus = ApiStatus.initial,
    this.likeByUserApiStatus = ApiStatus.initial,
    this.getOtherUserPostApiStatus = ApiStatus.initial,
    this.getMyPostApiStatus = ApiStatus.initial,
    this.isBlockScroll = false,
    this.isLoadMorePost = false,
    this.hasMorePost = true,
    this.isLoadMoreMyPost = false,
    this.hasMoreMyPost = true,
    this.isLoadMoreOtherUserPost = false,
    this.hasMoreOtherUserPost = true,
    this.likedByUserData,
    this.myPostData,
    this.otherUserPostData,
    this.showReplies,
    this.commentDataList,
    this.allPostData,
    this.errorMessage,
    this.statusCode,
  });

  PostState copyWith({
    ApiStatus? createPostApiStatus,
    ApiStatus? getAllPostApiStatus,
    ApiStatus? getPostCommentListApiStatus,
    ApiStatus? getRepliesApiStatus,
    ApiStatus? deletePostApiStatus,
    ApiStatus? archivePostApiStatus,
    ApiStatus? likeByUserApiStatus,
    ApiStatus? getMyPostApiStatus,
    ApiStatus? getOtherUserPostApiStatus,
    List<PostData>? allPostData,
    List<PostData>? otherUserPostData,
    List<PostData>? myPostData,
    List<User>? likedByUserData,
    Map<String, bool>? showReplies,
    List<CommentData>? commentDataList,
    bool? isBlockScroll,
    bool? hasMorePost,
    bool? isLoadMorePost,
    bool? hasMoreMyPost,
    bool? isLoadMoreMyPost,
    bool? isLoadMoreOtherUserPost,
    bool? hasMoreOtherUserPost,
    int? statusCode,
    String? errorMessage,
  }) {
    return PostState(
      createPostApiStatus: createPostApiStatus ?? this.createPostApiStatus,
      getAllPostApiStatus: getAllPostApiStatus ?? this.getAllPostApiStatus,
      getPostCommentListApiStatus: getPostCommentListApiStatus ?? this.getPostCommentListApiStatus,
      getRepliesApiStatus: getRepliesApiStatus ?? this.getRepliesApiStatus,
      deletePostApiStatus: deletePostApiStatus ?? this.deletePostApiStatus,
      archivePostApiStatus: archivePostApiStatus ?? this.archivePostApiStatus,
      likeByUserApiStatus: likeByUserApiStatus ?? this.likeByUserApiStatus,
      getMyPostApiStatus: getMyPostApiStatus ?? this.getMyPostApiStatus,
      getOtherUserPostApiStatus: getOtherUserPostApiStatus ?? this.getOtherUserPostApiStatus,
      likedByUserData: likedByUserData ?? this.likedByUserData,
      myPostData: myPostData ?? this.myPostData,
      otherUserPostData: otherUserPostData ?? this.otherUserPostData,
      showReplies: showReplies ?? this.showReplies,
      allPostData: allPostData ?? this.allPostData,
      commentDataList: commentDataList ?? this.commentDataList,
      isBlockScroll: isBlockScroll ?? this.isBlockScroll,
      isLoadMorePost: isLoadMorePost ?? this.isLoadMorePost,
      hasMoreMyPost: hasMoreMyPost ?? this.hasMoreMyPost,
      isLoadMoreMyPost: isLoadMoreMyPost ?? this.isLoadMoreMyPost,
      hasMorePost: hasMorePost ?? this.hasMorePost,
      hasMoreOtherUserPost: hasMoreOtherUserPost ?? this.hasMoreOtherUserPost,
      isLoadMoreOtherUserPost: isLoadMoreOtherUserPost ?? this.isLoadMoreOtherUserPost,
      errorMessage: errorMessage,
      statusCode: statusCode,
    );
  }

  @override
  List<Object?> get props => [
        createPostApiStatus,
        getAllPostApiStatus,
        getPostCommentListApiStatus,
        getRepliesApiStatus,
        deletePostApiStatus,
        archivePostApiStatus,
        likeByUserApiStatus,
        likedByUserData,
        myPostData,
        otherUserPostData,
        getOtherUserPostApiStatus,
        getMyPostApiStatus,
        allPostData,
        showReplies,
        commentDataList,
        errorMessage,
        isLoadMorePost,
        isLoadMoreMyPost,
        hasMoreMyPost,
        hasMorePost,
        isBlockScroll,
        isLoadMoreOtherUserPost,
        hasMoreOtherUserPost,
        statusCode,
      ];
}
