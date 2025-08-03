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

class GetPostCommentDataEvent extends PostEvent {
  final String postId;
  GetPostCommentDataEvent({required this.postId});
}

class GetCommentRepliesEvent extends PostEvent {
  final String commentId;
  final int skip;
  final int take;
  GetCommentRepliesEvent({required this.commentId, this.skip = 0, this.take = 10});
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
