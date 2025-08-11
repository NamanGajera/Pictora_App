part of 'follow_section_bloc.dart';

class FollowSectionEvent {}

class GetFollowersEvent extends FollowSectionEvent {
  final String userId;

  GetFollowersEvent({required this.userId});
}

class GetFollowingEvent extends FollowSectionEvent {
  final String userId;

  GetFollowingEvent({required this.userId});
}

class GetFollowRequestEvent extends FollowSectionEvent {}

class GetDiscoverUsersEvent extends FollowSectionEvent {}

class ToggleFollowUserEvent extends FollowSectionEvent {
  final String userId;
  final bool isFollowing;

  ToggleFollowUserEvent({
    required this.userId,
    required this.isFollowing,
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
