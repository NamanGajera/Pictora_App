part of 'post_bloc.dart';

class PostState extends Equatable {
  final ApiStatus createPostApiStatus;
  final ApiStatus getAllPostApiStatus;
  final ApiStatus getPostCommentListApiStatus;
  final ApiStatus getRepliesApiStatus;
  final ApiStatus deletePostApiStatus;
  final ApiStatus archivePostApiStatus;
  final Map<String, bool>? showReplies;
  final List<PostData>? allPostData;
  final List<CommentData>? commentDataList;
  final int? statusCode;
  final String? errorMessage;

  const PostState({
    this.createPostApiStatus = ApiStatus.initial,
    this.getAllPostApiStatus = ApiStatus.initial,
    this.getPostCommentListApiStatus = ApiStatus.initial,
    this.getRepliesApiStatus = ApiStatus.initial,
    this.deletePostApiStatus = ApiStatus.initial,
    this.archivePostApiStatus = ApiStatus.initial,
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
    List<PostData>? allPostData,
    Map<String, bool>? showReplies,
    List<CommentData>? commentDataList,
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
      showReplies: showReplies ?? this.showReplies,
      allPostData: allPostData ?? this.allPostData,
      commentDataList: commentDataList ?? this.commentDataList,
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
        allPostData,
        showReplies,
        commentDataList,
        errorMessage,
        statusCode,
      ];
}
