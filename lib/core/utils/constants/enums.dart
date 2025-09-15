enum PostCommentApiStatus {
  posting,
  success,
  failure,
  deleting,
  failedToDelete,
}

enum ApiStatus {
  initial,
  loading,
  success,
  failure,
}

enum AppEnv {
  local,
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
}

enum FollowSectionTab {
  follower,
  following,
  request,
  discover,
}

enum FollowRequest {
  pending("Pending"),
  accepted("Accepted"),
  rejected("Rejected");

  final String name;

  const FollowRequest(this.name);
}

enum PostListNavigation {
  search,
  myProfile,
  otherProfile,
  like,
  save,
  archive,
}

enum Gender {
  male("Male"),
  female("Female"),
  other("Other");

  final String name;

  const Gender(this.name);
}

enum ConversationMessageAttachmentType {
  image("Image"),
  video("Video"),
  audio("Audio"),
  link("Link");

  final String name;

  const ConversationMessageAttachmentType(this.name);
}
