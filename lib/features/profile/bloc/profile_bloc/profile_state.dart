part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final ApiStatus getUserDataApiStatus;
  final User? userData;
  final User? otherUserData;
  final int? statusCode;
  final String? errorMessage;
  final String? updatedUserProfileCacheKey;

  const ProfileState({
    this.getUserDataApiStatus = ApiStatus.initial,
    this.userData,
    this.otherUserData,
    this.errorMessage,
    this.statusCode,
    this.updatedUserProfileCacheKey,
  });

  ProfileState copyWith({
    ApiStatus? getUserDataApiStatus,
    User? userData,
    User? otherUserData,
    int? statusCode,
    String? errorMessage,
    String? updatedUserProfileCacheKey,
  }) {
    return ProfileState(
      getUserDataApiStatus: getUserDataApiStatus ?? this.getUserDataApiStatus,
      userData: userData ?? this.userData,
      otherUserData: otherUserData ?? this.otherUserData,
      updatedUserProfileCacheKey: updatedUserProfileCacheKey ?? this.updatedUserProfileCacheKey,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        getUserDataApiStatus,
        userData,
        otherUserData,
        updatedUserProfileCacheKey,
        errorMessage,
        statusCode,
      ];
}
