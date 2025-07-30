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
