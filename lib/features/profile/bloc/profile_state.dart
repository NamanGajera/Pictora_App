part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final ApiStatus getUserDataApiStatus;
  final User? userData;
  final User? otherUserData;
  final int? statusCode;
  final String? errorMessage;

  const ProfileState({
    this.getUserDataApiStatus = ApiStatus.initial,
    this.userData,
    this.otherUserData,
    this.errorMessage,
    this.statusCode,
  });

  ProfileState copyWith({
    ApiStatus? getUserDataApiStatus,
    User? userData,
    User? otherUserData,
    int? statusCode,
    String? errorMessage,
  }) {
    return ProfileState(
      getUserDataApiStatus: getUserDataApiStatus ?? this.getUserDataApiStatus,
      userData: userData ?? this.userData,
      otherUserData: otherUserData ?? this.otherUserData,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        getUserDataApiStatus,
        userData,
        otherUserData,
        errorMessage,
        statusCode,
      ];
}
