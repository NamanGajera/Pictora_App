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
