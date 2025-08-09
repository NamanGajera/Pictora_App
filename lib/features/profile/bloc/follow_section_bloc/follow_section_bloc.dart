import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/network/repository.dart';
import 'package:pictora/utils/Constants/enums.dart';

import '../../../../model/user_model.dart';
import '../../../../utils/helper/helper_function.dart';
import '../../../../utils/helper/theme_helper.dart';
import '../../model/follow_request_model.dart';

part 'follow_section_event.dart';
part 'follow_section_state.dart';

class FollowSectionBloc extends Bloc<FollowSectionEvent, FollowSectionState> {
  final Repository repository;
  FollowSectionBloc(this.repository) : super(FollowSectionState()) {
    on<GetFollowersEvent>(_getFollowers, transformer: droppable());
    on<GetFollowingEvent>(_getFollowing, transformer: droppable());
    on<GetDiscoverUsersEvent>(_getDiscoverUsers, transformer: droppable());
    on<GetFollowRequestEvent>(_getFollowRequests, transformer: droppable());
  }

  Future<void> _getFollowers(GetFollowersEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(getFollowersApiStatus: ApiStatus.loading));
      final followers = await repository.getFollowers(body: {'userId': event.userId});
      emit(state.copyWith(
        getFollowersApiStatus: ApiStatus.success,
        followers: followers.data ?? [],
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getFollowersApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getFollowing(GetFollowingEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(getFollowingApiStatus: ApiStatus.loading));
      final following = await repository.getFollowing(body: {'userId': event.userId});
      emit(state.copyWith(
        getFollowingApiStatus: ApiStatus.success,
        following: following.data ?? [],
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getFollowingApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getFollowRequests(GetFollowRequestEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(getFollowRequestApiStatus: ApiStatus.loading));
      final requests = await repository.getFollowRequests();
      emit(state.copyWith(
        getFollowRequestApiStatus: ApiStatus.success,
        followRequests: requests.data ?? [],
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getFollowRequestApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getDiscoverUsers(GetDiscoverUsersEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(getDiscoverUsersApiStatus: ApiStatus.loading));
      final users = await repository.getDiscoverUsers(body: {
        "skip": 0,
        "take": 25,
      });
      emit(state.copyWith(
        getDiscoverUsersApiStatus: ApiStatus.success,
        discoverUsers: users.data ?? [],
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getDiscoverUsersApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  void handleApiError(dynamic error, dynamic stackTrace, Emitter<FollowSectionState> emit) {
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
