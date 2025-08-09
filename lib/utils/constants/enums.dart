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
