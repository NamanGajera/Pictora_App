class PostModel {
  final String id;
  final String username;
  final String userAvatar;
  final String timeAgo;
  final String caption;
  final List<String> mediaUrls;
  int likes;
  bool isLiked;
  bool isSaved;
  final int comments;

  PostModel({
    required this.id,
    required this.username,
    required this.userAvatar,
    required this.timeAgo,
    required this.caption,
    required this.mediaUrls,
    required this.likes,
    required this.isLiked,
    required this.isSaved,
    required this.comments,
  });
}
