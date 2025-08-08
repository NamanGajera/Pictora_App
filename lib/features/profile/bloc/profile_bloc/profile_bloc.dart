import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/network/repository.dart';
import 'package:pictora/utils/Constants/enums.dart';

import '../../../../model/user_model.dart';
import '../../../../utils/helper/helper_function.dart';
import '../../../../utils/helper/theme_helper.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Repository repository;

  ProfileBloc(this.repository) : super(ProfileState()) {
    on<GetUserDataEvent>(_getUserData);
  }

  Future<void> _getUserData(GetUserDataEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(getUserDataApiStatus: ApiStatus.loading));
      User? myData;
      User? otherData;
      if (event.userId != null) {
        otherData = await repository.getUserData(event.userId);
      } else {
        myData = await repository.getUserData();
      }

      emit(state.copyWith(
        getUserDataApiStatus: ApiStatus.success,
        userData: myData,
        otherUserData: otherData,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getUserDataApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
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
}
