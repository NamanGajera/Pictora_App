part of 'follow_section_bloc.dart';

class FollowSectionState extends Equatable {
  final ApiStatus getFollowersApiStatus;
  final ApiStatus getFollowingApiStatus;
  final ApiStatus getFollowRequestApiStatus;
  final ApiStatus getDiscoverUsersApiStatus;
  final ApiStatus toggleFollowApiStatus;
  final List<User>? followers;
  final List<User>? following;
  final List<Request>? followRequests;
  final List<User>? discoverUsers;
  final String? errorMessage;
  final int? statusCode;

  const FollowSectionState({
    this.getFollowersApiStatus = ApiStatus.initial,
    this.getFollowingApiStatus = ApiStatus.initial,
    this.getFollowRequestApiStatus = ApiStatus.initial,
    this.getDiscoverUsersApiStatus = ApiStatus.initial,
    this.toggleFollowApiStatus = ApiStatus.initial,
    this.followers,
    this.following,
    this.discoverUsers,
    this.followRequests,
    this.errorMessage,
    this.statusCode,
  });

  FollowSectionState copyWith({
    ApiStatus? getFollowersApiStatus,
    ApiStatus? getFollowingApiStatus,
    ApiStatus? getFollowRequestApiStatus,
    ApiStatus? getDiscoverUsersApiStatus,
    ApiStatus? toggleFollowApiStatus,
    List<User>? followers,
    List<User>? following,
    List<Request>? followRequests,
    List<User>? discoverUsers,
    String? errorMessage,
    int? statusCode,
  }) {
    return FollowSectionState(
      getFollowersApiStatus: getFollowersApiStatus ?? this.getFollowersApiStatus,
      getFollowingApiStatus: getFollowingApiStatus ?? this.getFollowingApiStatus,
      getDiscoverUsersApiStatus: getDiscoverUsersApiStatus ?? this.getDiscoverUsersApiStatus,
      getFollowRequestApiStatus: getFollowRequestApiStatus ?? this.getFollowRequestApiStatus,
      toggleFollowApiStatus: toggleFollowApiStatus ?? this.toggleFollowApiStatus,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followRequests: followRequests ?? this.followRequests,
      discoverUsers: discoverUsers ?? this.discoverUsers,
      errorMessage: errorMessage,
      statusCode: statusCode,
    );
  }

  @override
  List<Object?> get props => [
        getFollowersApiStatus,
        getFollowingApiStatus,
        getDiscoverUsersApiStatus,
        getFollowRequestApiStatus,
        toggleFollowApiStatus,
        followers,
        following,
        discoverUsers,
        followRequests,
        errorMessage,
        statusCode,
      ];
}
