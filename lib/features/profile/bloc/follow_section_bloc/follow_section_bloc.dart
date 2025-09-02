// Third-party
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pictora/features/post/bloc/post_bloc.dart';

// Project
import '../profile_bloc/profile_bloc.dart';
import '../../../../core/utils/services/service.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../model/follow_request_model.dart';
import '../../repository/profile_repository.dart';

part 'follow_section_event.dart';
part 'follow_section_state.dart';

class FollowSectionBloc extends Bloc<FollowSectionEvent, FollowSectionState> {
  final ProfileRepository profileRepository;
  FollowSectionBloc(this.profileRepository) : super(FollowSectionState()) {
    on<GetFollowersEvent>(_getFollowers, transformer: droppable());
    on<LoadMoreFollowersEvent>(_loadMoreFollower, transformer: droppable());
    on<GetFollowingEvent>(_getFollowing, transformer: droppable());
    on<LoadMoreFollowingEvent>(_loadMoreFollowing, transformer: droppable());
    on<GetDiscoverUsersEvent>(_getDiscoverUsers, transformer: droppable());
    on<LoadMoreDiscoverUserEvent>(_loadMoreDiscoverUsers, transformer: droppable());
    on<GetFollowRequestEvent>(_getFollowRequests, transformer: droppable());
    on<ToggleFollowUserEvent>(_toggleFollowUser, transformer: droppable());
    on<ManageFollowRequestEvent>(_manageFollowRequest, transformer: droppable());
    on<ShowDiscoverUserOnProfileEvent>(_showDiscoverUser, transformer: droppable());
  }

  Future<void> _getFollowers(GetFollowersEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(getFollowersApiStatus: ApiStatus.loading));
      final followers = await profileRepository.getFollowers(body: {'userId': event.userId});
      emit(state.copyWith(
        getFollowersApiStatus: ApiStatus.success,
        followers: followers.data ?? [],
        hasMoreFollowers: (followers.data ?? []).length < (followers.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getFollowersApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreFollower(LoadMoreFollowersEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreFollowers: true));
      final followers = await profileRepository.getFollowers(body: event.body);
      emit(state.copyWith(
        isLoadMoreFollowers: false,
        followers: [...(state.followers ?? []), ...(followers.data ?? [])],
        hasMoreFollowers: [...(state.followers ?? []), ...(followers.data ?? [])].length < (followers.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreFollowers: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getFollowing(GetFollowingEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(getFollowingApiStatus: ApiStatus.loading));
      final following = await profileRepository.getFollowing(body: {'userId': event.userId});
      emit(state.copyWith(
        getFollowingApiStatus: ApiStatus.success,
        following: following.data ?? [],
        hasMoreFollowers: (following.data ?? []).length < (following.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getFollowingApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreFollowing(LoadMoreFollowingEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreFollowing: true));
      final following = await profileRepository.getFollowing(body: event.body);
      emit(state.copyWith(
        isLoadMoreFollowing: false,
        following: [...(state.following ?? []), ...(following.data ?? [])],
        hasMoreFollowing: [...(state.following ?? []), ...(following.data ?? [])].length < (following.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreFollowing: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _getFollowRequests(GetFollowRequestEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(getFollowRequestApiStatus: ApiStatus.loading));
      final requests = await profileRepository.getFollowRequests();
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
      final users = await profileRepository.getDiscoverUsers(body: {
        "skip": 0,
        "take": 20,
      });
      emit(state.copyWith(
        getDiscoverUsersApiStatus: ApiStatus.success,
        discoverUsers: users.data ?? [],
        hasMoreDiscover: (users.data ?? []).length < (users.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getDiscoverUsersApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _loadMoreDiscoverUsers(LoadMoreDiscoverUserEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(isLoadMoreDiscover: true));
      final users = await profileRepository.getDiscoverUsers(body: event.body);
      emit(state.copyWith(
        isLoadMoreDiscover: false,
        discoverUsers: [...(state.discoverUsers ?? []), ...(users.data ?? [])],
        hasMoreDiscover: [...(state.discoverUsers ?? []), ...(users.data ?? [])].length < (users.total ?? 0),
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(isLoadMoreDiscover: false));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _toggleFollowUser(ToggleFollowUserEvent event, Emitter<FollowSectionState> emit) async {
    try {
      final bool isInFollower = state.followers?.any((user) => user.id == event.userId) ?? false;

      _updateUserLists(
        emit: emit,
        userId: event.userId,
        isFollowed: event.isFollowing,
        isInFollowing: !isInFollower,
      );

      if (event.postId != null) {
        postBloc.add(UpdatePostUserDataEvent(
          userId: event.userId,
          postId: event.postId ?? '',
          isFollowed: event.isFollowing,
          isInFollowing: !isInFollower,
        ));
      }
      logDebug(message: "IsPrivate ==>>>> ${event.isPrivate}");
      if (!(event.isPrivate ?? false)) {
        profileBloc.add(
          ModifyUserCountEvent(
            followingCount: event.isFollowing == true ? 1 : -1,
          ),
        );
      }
      profileBloc.add(
        ModifyUserDataEvent(
          userId: event.userId,
          isFollowed: event.isFollowing,
          isInFollowing: !isInFollower,
        ),
      );
      await profileRepository.toggleUserFollow(body: {
        "userId": event.userId,
        "shouldFollow": event.isFollowing,
      });
    } catch (error, stackTrace) {
      _updateUserLists(
        emit: emit,
        userId: event.userId,
        isFollowed: !event.isFollowing,
      );
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _manageFollowRequest(ManageFollowRequestEvent event, Emitter<FollowSectionState> emit) async {
    try {
      emit(state.copyWith(manageFollowRequestApiStatus: ApiStatus.loading));
      await profileRepository.manageFollowRequest(body: {
        "id": event.requestId,
        "isAccept": event.isAccept,
      });
      final List<Request> requests = (state.followRequests ?? []).where((request) => request.id != event.requestId).toList();

      emit(state.copyWith(
        followRequests: requests,
        manageFollowRequestApiStatus: ApiStatus.success,
      ));
      final bool isInFollowing = state.following?.any((user) => user.id == event.userId) ?? false;
      _updateUserLists(emit: emit, userId: event.userId, isInFollowing: isInFollowing);
      profileBloc.add(ModifyUserCountEvent(followersCount: 1));
    } catch (error, stackTrace) {
      emit(state.copyWith(manageFollowRequestApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  void _showDiscoverUser(ShowDiscoverUserOnProfileEvent event, Emitter<FollowSectionState> emit) {
    emit(state.copyWith(showDiscoverUserOnProfile: event.showUser));
    if (event.showUser) {
      add(GetDiscoverUsersEvent());
    }
  }

  void _updateUserLists({required Emitter<FollowSectionState> emit, required String userId, bool? isFollowed, bool? isInFollowing}) {
    emit(state.copyWith(
      followers: _updateUserData(
        userList: state.followers,
        userId: userId,
        isFollowed: isFollowed,
        isInFollowing: isInFollowing,
      ),
      following: _updateUserData(
        userList: state.following,
        userId: userId,
        isFollowed: isFollowed,
        isInFollowing: isInFollowing,
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
    logDebug(message: "Data-->>>> userId--> $userId,, isFollowed--> $isFollowed,, isInFollowing--> $isInFollowing");
    return (userList ?? []).map((user) {
      if (user.id == userId) {
        return user.copyWith(
          isFollowed: isFollowed ?? user.isFollowed,
          showFollowBack: isInFollowing == null ? user.showFollowBack : !isInFollowing,
          followRequestStatus: (user.profile?.isPrivate ?? false) && isFollowed == true ? FollowRequest.pending.name : null,
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
