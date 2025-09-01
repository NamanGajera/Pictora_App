part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final ApiStatus getUserDataApiStatus;
  final ApiStatus updateUserDataApiStatus;
  final ApiStatus changeAccountPrivacyApiStatus;
  final User? userData;
  final User? otherUserData;
  final int? statusCode;
  final String? errorMessage;
  final String? updatedUserProfileCacheKey;

  const ProfileState({
    this.getUserDataApiStatus = ApiStatus.initial,
    this.updateUserDataApiStatus = ApiStatus.initial,
    this.changeAccountPrivacyApiStatus = ApiStatus.initial,
    this.userData,
    this.otherUserData,
    this.errorMessage,
    this.statusCode,
    this.updatedUserProfileCacheKey,
  });

  ProfileState copyWith({
    ApiStatus? getUserDataApiStatus,
    ApiStatus? updateUserDataApiStatus,
    ApiStatus? changeAccountPrivacyApiStatus,
    User? userData,
    User? otherUserData,
    int? statusCode,
    String? errorMessage,
    String? updatedUserProfileCacheKey,
  }) {
    return ProfileState(
      getUserDataApiStatus: getUserDataApiStatus ?? this.getUserDataApiStatus,
      updateUserDataApiStatus: updateUserDataApiStatus ?? this.updateUserDataApiStatus,
      changeAccountPrivacyApiStatus: changeAccountPrivacyApiStatus ?? this.changeAccountPrivacyApiStatus,
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
        updateUserDataApiStatus,
        userData,
        otherUserData,
        updatedUserProfileCacheKey,
        changeAccountPrivacyApiStatus,
        errorMessage,
        statusCode,
      ];
}
