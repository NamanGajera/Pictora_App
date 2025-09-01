// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import '../model/auth_model.dart';
import '../repository/auth_repository.dart';
import '../../../core/config/router.dart';
import '../../../core/config/router_name.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/model/user_model.dart';
import '../../../core/utils/helper/helper.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc(this.authRepository) : super(AuthState()) {
    on<RegisterUserEvent>(_register);
    on<LoginUserEvent>(_login);
  }
  Future<void> _register(RegisterUserEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(registerUserApiStatus: ApiStatus.loading));

      final data = await authRepository.registerUser(event.body);
      await setUserData(data);
      emit(state.copyWith(registerUserApiStatus: ApiStatus.success));
    } catch (error, stackTrace) {
      emit(state.copyWith(registerUserApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _login(LoginUserEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(loginUserApiStatus: ApiStatus.loading));

      final data = await authRepository.login(event.body);
      await setUserData(data);
      emit(state.copyWith(loginUserApiStatus: ApiStatus.success));
    } catch (error, stackTrace) {
      emit(state.copyWith(loginUserApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> setUserData(AuthModel? authModel) async {
    accessToken = authModel?.data?.token;
    User? userData = authModel?.data?.user;

    userId = userData?.id;
    userFullName = userData?.fullName;
    userEmail = userData?.email;
    userName = userData?.userName;
    userProfilePic = userData?.profile?.profilePicture ?? '';
    isPrivateAccount = userData?.profile?.isPrivate;

    SharedPrefsHelper().setString(SharedPrefKeys.accessToken, accessToken ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userId, userId ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userEmail, userEmail ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userFullName, userFullName ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userName, userName ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userProfilePic, userProfilePic ?? '');
    SharedPrefsHelper().setBool(SharedPrefKeys.isPrivateAccount, isPrivateAccount ?? false);

    appRouter.go(RouterName.home.path);
  }

  void handleApiError(dynamic error, dynamic stackTrace, Emitter<AuthState> emit) {
    handleError(
      error: error,
      stackTrace: stackTrace,
      emit: emit,
      stateCopyWith: (statusCode, errorMessage) => state.copyWith(
        statusCode: statusCode,
        errorMessage: errorMessage,
      ),
    );
  }
}
