part of 'auth_bloc.dart';

@immutable
class AuthState extends Equatable {
  final ApiStatus registerUserApiStatus;
  final ApiStatus loginUserApiStatus;
  final int? statusCode;
  final String? errorMessage;
  const AuthState({
    this.registerUserApiStatus = ApiStatus.initial,
    this.loginUserApiStatus = ApiStatus.initial,
    this.statusCode,
    this.errorMessage,
  });

  AuthState copyWith({
    ApiStatus? registerUserApiStatus,
    ApiStatus? loginUserApiStatus,
    int? statusCode,
    String? errorMessage,
  }) {
    return AuthState(
      registerUserApiStatus:
          registerUserApiStatus ?? this.registerUserApiStatus,
      loginUserApiStatus: loginUserApiStatus ?? this.loginUserApiStatus,
      statusCode: statusCode,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        registerUserApiStatus,
        loginUserApiStatus,
        statusCode,
        errorMessage,
      ];
}
