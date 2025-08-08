part of 'follow_section_bloc.dart';

class FollowSectionState extends Equatable {
  final ApiStatus getFollowersApiStatus;
  final ApiStatus getFollowingApiStatus;
  final List<User>? followers;
  final List<User>? following;
  final String? errorMessage;
  final int? statusCode;

  const FollowSectionState({
    this.getFollowersApiStatus = ApiStatus.initial,
    this.getFollowingApiStatus = ApiStatus.initial,
    this.followers,
    this.following,
    this.errorMessage,
    this.statusCode,
  });

  FollowSectionState copyWith({
    ApiStatus? getFollowersApiStatus,
    ApiStatus? getFollowingApiStatus,
    List<User>? followers,
    List<User>? following,
    String? errorMessage,
    int? statusCode,
  }) {
    return FollowSectionState(
      getFollowersApiStatus: getFollowersApiStatus ?? this.getFollowersApiStatus,
      getFollowingApiStatus: getFollowingApiStatus ?? this.getFollowingApiStatus,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      errorMessage: errorMessage,
      statusCode: statusCode,
    );
  }

  @override
  List<Object?> get props => [
        getFollowersApiStatus,
        getFollowingApiStatus,
        followers,
        following,
        errorMessage,
        statusCode,
      ];
}
