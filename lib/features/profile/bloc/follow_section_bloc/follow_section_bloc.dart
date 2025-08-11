import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/network/repository.dart';
import 'package:pictora/utils/Constants/enums.dart';
import 'package:pictora/utils/services/custom_logger.dart';

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
    on<ToggleFollowUserEvent>(_toggleFollowUser, transformer: droppable());
    on<ManageFollowRequestEvent>(_manageFollowRequest, transformer: droppable());
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

  Future<void> _toggleFollowUser(ToggleFollowUserEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(toggleFollowApiStatus: ApiStatus.loading));
      _updateUserLists(
        emit: emit,
        userId: event.userId,
        isFollowed: event.isFollowing,
      );
    } catch (error, stackTrace) {
      emit(state.copyWith(toggleFollowApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _manageFollowRequest(ManageFollowRequestEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(toggleFollowApiStatus: ApiStatus.loading));

      final List<Request> requests = (state.followRequests ?? []).where((request) => request.id != event.requestId).toList();
      emit(state.copyWith(
        followRequests: requests,
        toggleFollowApiStatus: ApiStatus.success,
      ));
      final bool isInFollowing = state.following?.any((user) => user.id == event.userId) ?? false;
      _updateUserLists(emit: emit, userId: event.userId, isInFollowing: isInFollowing);
    } catch (error, stackTrace) {
      emit(state.copyWith(toggleFollowApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  void _updateUserLists({required Emitter<FollowSectionState> emit, required String userId, bool? isFollowed, bool? isInFollowing}) {
    logInfo(message: "Updating user lists for userId: $userId, isFollowed: $isFollowed, isInFollowing: $isInFollowing", tag: "ToggleFollowUserEvent");
    emit(state.copyWith(
      followers: _updateUserData(
        userList: state.followers,
        userId: userId,
        isFollowed: isFollowed,
      ),
      following: _updateUserData(
        userList: state.following,
        userId: userId,
        isFollowed: isFollowed,
      ),
      discoverUsers: _updateUserData(
        userList: state.discoverUsers,
        userId: userId,
        isFollowed: isFollowed,
        isInFollowing: isInFollowing,
      ),
    ));
  }

  List<User> _updateUserData({
    required List<User>? userList,
    required String userId,
    bool? isFollowed,
    bool? isInFollowing,
  }) {
    return (userList ?? []).map((user) {
      if (user.id == userId) {
        return user.copyWith(
          isFollowed: isFollowed ?? user.isFollowed,
          showFollowBack: isInFollowing == null ? user.showFollowBack : !isInFollowing,
        );
      }
      return user;
    }).toList();
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
