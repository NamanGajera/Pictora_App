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
