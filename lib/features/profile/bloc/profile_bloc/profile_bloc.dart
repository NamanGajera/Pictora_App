// Dart SDK
import 'dart:io';

// Third-party
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project
import '../../../../core/config/router.dart';
import '../../../../core/utils/model/user_model.dart';
import '../../../../core/utils/constants/constants.dart';
import '../../../../core/utils/helper/helper.dart';
import '../../../../core/utils/widgets/custom_overlay.dart';
import '../../../../core/utils/widgets/custom_widget.dart';
import '../../repository/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc(this.profileRepository) : super(ProfileState()) {
    on<GetUserDataEvent>(_getUserData);
    on<ModifyUserCountEvent>(_modifyUserCounts, transformer: sequential());
    on<ModifyUserDataEvent>(_modifyUserData, transformer: sequential());
    on<UpdateProfilePictureEvent>(_updateProfilePicture, transformer: droppable());
  }

  Future<void> _getUserData(GetUserDataEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(state.copyWith(getUserDataApiStatus: ApiStatus.loading));
      User? myData;
      User? otherData;
      if (event.userId != null) {
        otherData = await profileRepository.getUserData(event.userId);
      } else {
        myData = await profileRepository.getUserData();
      }

      emit(state.copyWith(
        getUserDataApiStatus: ApiStatus.success,
        userData: myData,
        otherUserData: otherData,
      ));
    } catch (error, stackTrace) {
      emit(state.copyWith(getUserDataApiStatus: ApiStatus.failure));
      ThemeHelper.showToastMessage("$error");
      handleApiError(error, stackTrace, emit);
    }
  }

  Future<void> _modifyUserCounts(ModifyUserCountEvent event, Emitter<ProfileState> emit) async {
    try {
      if (event.postsCount != null) {
        emit(state.copyWith(
          userData: state.userData
              ?.copyWith(counts: state.userData?.counts?.copyWith(postCount: (state.userData?.counts?.postCount ?? 0) + (event.postsCount ?? 0))),
        ));
      }

      if (event.followingCount != null) {
        emit(state.copyWith(
          userData: state.userData?.copyWith(
              counts: state.userData?.counts?.copyWith(followingCount: (state.userData?.counts?.followingCount ?? 0) + (event.followingCount ?? 0))),
        ));
      }

      if (event.followersCount != null) {
        emit(state.copyWith(
          userData: state.userData?.copyWith(
              counts: state.userData?.counts?.copyWith(followerCount: (state.userData?.counts?.followerCount ?? 0) + (event.followersCount ?? 0))),
        ));
      }
    } catch (error, stackTrace) {
      handleApiError(error, stackTrace, emit);
    }
  }

  void _modifyUserData(ModifyUserDataEvent event, Emitter<ProfileState> emit) {
    if (state.otherUserData?.id == event.userId) {
      emit(state.copyWith(
          otherUserData: state.otherUserData?.copyWith(
        isFollowed: event.isFollowed ?? state.otherUserData?.isFollowed,
        showFollowBack: event.isInFollowing == null ? state.otherUserData?.showFollowBack : !(event.isInFollowing ?? false),
        followRequestStatus: (state.otherUserData?.profile?.isPrivate ?? false) && event.isFollowed == true ? FollowRequest.pending.name : null,
      )));
    }
  }

  Future<void> _updateProfilePicture(UpdateProfilePictureEvent event, Emitter<ProfileState> emit) async {
    try {
      final userData = await profileRepository.updateUserData(
        body: <String, dynamic>{},
        fileField: {"profilePic": event.profilePicture},
      );
      userProfilePic = userData.profile?.profilePicture;
      emit(state.copyWith(
          userData: state.userData?.copyWith(
              profile: state.userData?.profile?.copyWith(
        profilePicture: userData.profile?.profilePicture,
      ))));
      await SharedPrefsHelper().setString(SharedPrefKeys.userProfilePic, userProfilePic ?? '');

      OverlayManager().show(
        context: navigatorKey.currentContext!,
        overlayId: OverlayIds.updateProfilePic,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CustomText(
                "Profile picture updated successfully",
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      Future.delayed(Duration(seconds: 2), () {
        OverlayManager().hideAll();
      });
    } catch (error, stackTrace) {
      handleApiError(error, stackTrace, emit);
    }
  }

  void handleApiError(dynamic error, dynamic stackTrace, Emitter<ProfileState> emit) {
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
