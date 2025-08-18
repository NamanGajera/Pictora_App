part of 'follow_section_bloc.dart';

class FollowSectionEvent {}

class GetFollowersEvent extends FollowSectionEvent {
  final String userId;

  GetFollowersEvent({required this.userId});
}

class LoadMoreFollowersEvent extends FollowSectionEvent {
  final Map<String, dynamic> body;

  LoadMoreFollowersEvent({required this.body});
}

class GetFollowingEvent extends FollowSectionEvent {
  final String userId;

  GetFollowingEvent({required this.userId});
}

class LoadMoreFollowingEvent extends FollowSectionEvent {
  final Map<String, dynamic> body;

  LoadMoreFollowingEvent({required this.body});
}

class GetFollowRequestEvent extends FollowSectionEvent {}

class GetDiscoverUsersEvent extends FollowSectionEvent {}

class LoadMoreDiscoverUserEvent extends FollowSectionEvent {
  final Map<String, dynamic> body;
  LoadMoreDiscoverUserEvent({required this.body});
}

class ToggleFollowUserEvent extends FollowSectionEvent {
  final String userId;
  final bool isFollowing;
  final bool? isPrivate;

  ToggleFollowUserEvent({
    required this.userId,
    required this.isFollowing,
    this.isPrivate,
  });
}

class ManageFollowRequestEvent extends FollowSectionEvent {
  final String requestId;
  final String userId;
  final bool isAccept;

  ManageFollowRequestEvent({
    required this.requestId,
    required this.userId,
    required this.isAccept,
  });
}
