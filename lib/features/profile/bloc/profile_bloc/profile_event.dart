part of 'profile_bloc.dart';

class ProfileEvent {}

class GetUserDataEvent extends ProfileEvent {
  final String? userId;
  GetUserDataEvent({this.userId});
}

class ModifyUserCountEvent extends ProfileEvent {
  final int? postsCount;
  final int? followersCount;
  final int? followingCount;
  ModifyUserCountEvent({
    this.postsCount,
    this.followersCount,
    this.followingCount,
  });
}

class ModifyUserDataEvent extends ProfileEvent {
  final String userId;
  final bool? isFollowed;
  final bool? isInFollowing;

  ModifyUserDataEvent({
    required this.userId,
    this.isFollowed,
    this.isInFollowing,
  });
}
