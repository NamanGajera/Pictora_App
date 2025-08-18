part of 'post_bloc.dart';

class PostEvent {}

class CreatePostEvent extends PostEvent {
  final String caption;
  final List<File> mediaData;
  final List<File>? thumbnailData;
  final File previewFile;

  CreatePostEvent({
    this.thumbnailData,
    required this.caption,
    required this.mediaData,
    required this.previewFile,
  });
}

class GetAllPostEvent extends PostEvent {
  final Map<String, dynamic> body;
  GetAllPostEvent({required this.body});
}

class LoadMorePostEvent extends PostEvent {
  final Map<String, dynamic> body;
  LoadMorePostEvent({required this.body});
}

class GetMyPostEvent extends PostEvent {
  final Map<String, dynamic> body;
  GetMyPostEvent({required this.body});
}

class LoadMoreMyPostEvent extends PostEvent {
  final Map<String, dynamic> body;
  LoadMoreMyPostEvent({required this.body});
}

class GetOtherUserPostsEvent extends PostEvent {
  final Map<String, dynamic> body;
  GetOtherUserPostsEvent({required this.body});
}

class LoadMoreOtherUserPostEvent extends PostEvent {
  final Map<String, dynamic> body;
  LoadMoreOtherUserPostEvent({required this.body});
}

class GetPostCommentDataEvent extends PostEvent {
  final String postId;
  GetPostCommentDataEvent({required this.postId});
}

class LoadMorePostCommentDataEvent extends PostEvent {
  final Map<String, dynamic> body;
  LoadMorePostCommentDataEvent({required this.body});
}

class GetCommentRepliesEvent extends PostEvent {
  final String commentId;
  final int skip;
  final int take;
  GetCommentRepliesEvent({required this.commentId, this.skip = 0, this.take = 10});
}

class LoadMoreCommentRepliesEvent extends PostEvent {
  final String commentId;
  final int skip;
  final int take;
  LoadMoreCommentRepliesEvent({required this.commentId, this.skip = 0, this.take = 10});
}

class CreateCommentEvent extends PostEvent {
  final String postId;
  final String comment;
  final String? commentParentId;
  final String? userId;
  CreateCommentEvent({
    required this.comment,
    required this.postId,
    this.commentParentId,
    required this.userId,
  });
}

class ClearRepliesData extends PostEvent {}

class ToggleCommentLikeEvent extends PostEvent {
  final String commentId;
  final bool isLike;
  ToggleCommentLikeEvent({
    required this.commentId,
    required this.isLike,
  });
}

class DeleteCommentEvent extends PostEvent {
  final String commentId;
  final String postId;
  DeleteCommentEvent({required this.commentId, required this.postId});
}

class TogglePostLikeEvent extends PostEvent {
  final String postId;
  final bool isLike;

  TogglePostLikeEvent({
    required this.postId,
    required this.isLike,
  });
}

class TogglePostSaveEvent extends PostEvent {
  final String postId;
  final bool isSave;

  TogglePostSaveEvent({
    required this.postId,
    required this.isSave,
  });
}

class DeletePostEvent extends PostEvent {
  final String postId;
  DeletePostEvent({required this.postId});
}

class ArchivePostEvent extends PostEvent {
  final String postId;
  final bool isArchive;
  ArchivePostEvent({required this.postId, required this.isArchive});
}

class GetLikedByUserEvent extends PostEvent {
  final String postId;
  GetLikedByUserEvent({
    required this.postId,
  });
}

class LoadMoreLikedByUserEvent extends PostEvent {
  final Map<String, dynamic> body;
  final String postId;
  LoadMoreLikedByUserEvent({required this.body, required this.postId});
}

class BlockScrollEvent extends PostEvent {
  final bool isBlockScroll;
  BlockScrollEvent({required this.isBlockScroll});
}

class GetAllExplorePostsEvent extends PostEvent {}
