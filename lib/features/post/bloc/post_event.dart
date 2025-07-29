part of 'post_bloc.dart';

class PostEvent {}

class CreatePostEvent extends PostEvent {
  final String caption;
  final List<File> mediaData;
  final List<File>? thumbnailData;

  CreatePostEvent({
    this.thumbnailData,
    required this.caption,
    required this.mediaData,
  });
}
