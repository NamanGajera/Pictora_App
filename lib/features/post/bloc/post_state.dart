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
  final ApiStatus getLikedPostApiStatus;
  final ApiStatus getSavedPostApiStatus;
  final ApiStatus getArchivedPostApiStatus;
  final ApiStatus getUserCommentApiStatus;
  final Map<String, bool>? showReplies;
  final List<PostData>? allPostData;
  final List<PostData>? otherUserPostData;
  final List<PostData>? myPostData;
  final List<PostData>? likedPostData;
  final List<PostData>? savedPostData;
  final List<PostData>? archivedPostData;
  final List<User>? likedByUserData;
  final List<CommentData>? commentDataList;
  final List<CommentData>? userCommentsData;
  final bool isBlockScroll;
  final bool isLoadMorePost;
  final bool hasMorePost;
  final bool isLoadMoreMyPost;
  final bool hasMoreMyPost;
  final bool hasMoreOtherUserPost;
  final bool isLoadMoreOtherUserPost;
  final bool isLoadMorePostComments;
  final bool hasMorePostComments;
  final bool isLoadMoreReplies;
  final bool hasMoreCommentReplies;
  final bool hasMoreLikedByUser;
  final bool isLoadMoreLikedByUser;
  final bool isLoadMoreLikedPost;
  final bool hasMoreLikedPost;
  final bool isLoadMoreSavedPost;
  final bool hasMoreSavedPost;
  final bool isLoadMoreArchivedPost;
  final bool hasMoreArchivedPost;
  final bool isLoadMoreUserComments;
  final bool hasMoreUserComments;
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
    this.getLikedPostApiStatus = ApiStatus.initial,
    this.getSavedPostApiStatus = ApiStatus.initial,
    this.getArchivedPostApiStatus = ApiStatus.initial,
    this.getUserCommentApiStatus = ApiStatus.initial,
    this.isBlockScroll = false,
    this.isLoadMorePost = false,
    this.hasMorePost = true,
    this.isLoadMoreMyPost = false,
    this.hasMoreMyPost = true,
    this.isLoadMoreOtherUserPost = false,
    this.hasMoreOtherUserPost = true,
    this.hasMorePostComments = true,
    this.isLoadMorePostComments = false,
    this.hasMoreCommentReplies = true,
    this.isLoadMoreReplies = false,
    this.hasMoreLikedByUser = true,
    this.isLoadMoreLikedByUser = false,
    this.isLoadMoreLikedPost = false,
    this.hasMoreLikedPost = true,
    this.isLoadMoreSavedPost = false,
    this.hasMoreSavedPost = true,
    this.isLoadMoreArchivedPost = false,
    this.hasMoreArchivedPost = true,
    this.isLoadMoreUserComments = false,
    this.hasMoreUserComments = true,
    this.savedPostData,
    this.userCommentsData,
    this.archivedPostData,
    this.likedByUserData,
    this.myPostData,
    this.otherUserPostData,
    this.showReplies,
    this.likedPostData,
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
    ApiStatus? getLikedPostApiStatus,
    ApiStatus? getSavedPostApiStatus,
    ApiStatus? getArchivedPostApiStatus,
    ApiStatus? getUserCommentApiStatus,
    List<PostData>? allPostData,
    List<PostData>? otherUserPostData,
    List<PostData>? myPostData,
    List<PostData>? likedPostData,
    List<PostData>? savedPostData,
    List<PostData>? archivedPostData,
    List<User>? likedByUserData,
    Map<String, bool>? showReplies,
    List<CommentData>? commentDataList,
    List<CommentData>? userCommentsData,
    bool? isBlockScroll,
    bool? hasMorePost,
    bool? isLoadMorePost,
    bool? isLoadMorePostComments,
    bool? hasMorePostComments,
    bool? hasMoreMyPost,
    bool? isLoadMoreMyPost,
    bool? isLoadMoreOtherUserPost,
    bool? hasMoreOtherUserPost,
    bool? isLoadMoreReplies,
    bool? hasMoreCommentReplies,
    bool? hasMoreLikedByUser,
    bool? isLoadMoreLikedByUser,
    bool? isLoadMoreLikedPost,
    bool? hasMoreLikedPost,
    bool? isLoadMoreSavedPost,
    bool? hasMoreSavedPost,
    bool? isLoadMoreArchivedPost,
    bool? hasMoreArchivedPost,
    bool? isLoadMoreUserComments,
    bool? hasMoreUserComments,
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
      getLikedPostApiStatus: getLikedPostApiStatus ?? this.getLikedPostApiStatus,
      getSavedPostApiStatus: getSavedPostApiStatus ?? this.getSavedPostApiStatus,
      likedByUserData: likedByUserData ?? this.likedByUserData,
      myPostData: myPostData ?? this.myPostData,
      otherUserPostData: otherUserPostData ?? this.otherUserPostData,
      likedPostData: likedPostData ?? this.likedPostData,
      showReplies: showReplies ?? this.showReplies,
      allPostData: allPostData ?? this.allPostData,
      savedPostData: savedPostData ?? this.savedPostData,
      commentDataList: commentDataList ?? this.commentDataList,
      isBlockScroll: isBlockScroll ?? this.isBlockScroll,
      isLoadMorePost: isLoadMorePost ?? this.isLoadMorePost,
      hasMoreMyPost: hasMoreMyPost ?? this.hasMoreMyPost,
      isLoadMoreMyPost: isLoadMoreMyPost ?? this.isLoadMoreMyPost,
      isLoadMorePostComments: isLoadMorePostComments ?? this.isLoadMorePostComments,
      hasMorePostComments: hasMorePostComments ?? this.hasMorePostComments,
      isLoadMoreReplies: isLoadMoreReplies ?? this.isLoadMoreReplies,
      hasMoreCommentReplies: hasMoreCommentReplies ?? this.hasMoreCommentReplies,
      hasMorePost: hasMorePost ?? this.hasMorePost,
      hasMoreOtherUserPost: hasMoreOtherUserPost ?? this.hasMoreOtherUserPost,
      isLoadMoreOtherUserPost: isLoadMoreOtherUserPost ?? this.isLoadMoreOtherUserPost,
      isLoadMoreLikedByUser: isLoadMoreLikedByUser ?? this.isLoadMoreLikedByUser,
      hasMoreLikedByUser: hasMoreLikedByUser ?? this.hasMoreLikedByUser,
      isLoadMoreLikedPost: isLoadMoreLikedPost ?? this.isLoadMoreLikedPost,
      hasMoreLikedPost: hasMoreLikedPost ?? this.hasMoreLikedPost,
      isLoadMoreSavedPost: isLoadMoreSavedPost ?? this.isLoadMoreSavedPost,
      hasMoreSavedPost: hasMoreSavedPost ?? this.hasMoreSavedPost,
      getArchivedPostApiStatus: getArchivedPostApiStatus ?? this.getArchivedPostApiStatus,
      archivedPostData: archivedPostData ?? this.archivedPostData,
      isLoadMoreArchivedPost: isLoadMoreArchivedPost ?? this.isLoadMoreArchivedPost,
      hasMoreArchivedPost: hasMoreArchivedPost ?? this.hasMoreArchivedPost,
      getUserCommentApiStatus: getUserCommentApiStatus ?? this.getUserCommentApiStatus,
      hasMoreUserComments: hasMoreUserComments ?? this.hasMoreUserComments,
      isLoadMoreUserComments: isLoadMoreUserComments ?? this.isLoadMoreUserComments,
      userCommentsData: userCommentsData ?? this.userCommentsData,
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
        likedPostData,
        getLikedPostApiStatus,
        isLoadMoreLikedPost,
        hasMoreLikedPost,
        hasMorePost,
        isBlockScroll,
        isLoadMoreOtherUserPost,
        hasMoreOtherUserPost,
        hasMorePostComments,
        isLoadMorePostComments,
        hasMoreCommentReplies,
        isLoadMoreReplies,
        hasMoreLikedByUser,
        getSavedPostApiStatus,
        savedPostData,
        isLoadMoreSavedPost,
        hasMoreSavedPost,
        getArchivedPostApiStatus,
        archivedPostData,
        isLoadMoreArchivedPost,
        hasMoreArchivedPost,
        isLoadMoreLikedByUser,
        getUserCommentApiStatus,
        hasMoreUserComments,
        isLoadMoreUserComments,
        userCommentsData,
        statusCode,
      ];
}
