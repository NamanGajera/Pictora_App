import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/auth/model/auth_model.dart';
import 'package:pictora/network/repository.dart';
import 'package:pictora/router/router.dart';
import 'package:pictora/router/router_name.dart';
import 'package:pictora/utils/constants/constants.dart';
import 'package:pictora/utils/constants/enums.dart';
import 'package:pictora/utils/constants/shared_pref_keys.dart';
import 'package:pictora/utils/helper/shared_prefs_helper.dart';
import 'package:pictora/utils/helper/theme_helper.dart';

import '../../../model/user_model.dart';
import '../../../utils/helper/helper_function.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Repository repository;
  AuthBloc(this.repository) : super(AuthState()) {
    on<RegisterUserEvent>(_register);
    on<LoginUserEvent>(_login);
  }
  Future<void> _register(RegisterUserEvent event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(registerUserApiStatus: ApiStatus.loading));

      final data = await repository.registerUser(event.body);
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

      final data = await repository.login(event.body);
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

    SharedPrefsHelper().setString(SharedPrefKeys.accessToken, accessToken ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userId, userId ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userEmail, userEmail ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userFullName, userFullName ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userName, userName ?? '');
    SharedPrefsHelper().setString(SharedPrefKeys.userProfilePic, userProfilePic ?? '');

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
