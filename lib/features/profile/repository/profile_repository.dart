import 'package:pictora/core/network/api_client.dart';

import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/helper/helper.dart';
import '../../../core/utils/model/common_message_model.dart';
import '../../../core/utils/model/user_list_data_model.dart';
import '../../../core/utils/model/user_model.dart';
import '../model/follow_request_model.dart';

class ProfileRepository {
  ApiClient apiClient;

  ProfileRepository(this.apiClient);

  /// GET: USER DATA
  Future<User> getUserData([String? userId]) async {
    try {
      Map<String, dynamic> json = await apiClient.getApiCall(
        endPoint: userId != null ? "$userRoute/$userId" : userRoute,
        isAccessToken: accessToken,
      );

      return User.fromJson(json["data"]);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET FOLLOWERS
  Future<UserListDataModel> getFollowers({required dynamic body}) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: getFollowersApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return UserListDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET FOLLOWING
  Future<UserListDataModel> getFollowing({required dynamic body}) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: getFollowingApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return UserListDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// GET: GET FOLLOW REQUESTS
  Future<FollowRequestsModel> getFollowRequests() async {
    try {
      Map<String, dynamic> json = await apiClient.getApiCall(
        endPoint: followRequestUserApiEndPoint,
        isAccessToken: accessToken,
      );

      return FollowRequestsModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET DISCOVER USERS
  Future<UserListDataModel> getDiscoverUsers({required dynamic body}) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: getDiscoverUserApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return UserListDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: TOGGLE USER FOLLOW
  Future<UserListDataModel> toggleUserFollow({required dynamic body}) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: toggleFollowUserApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return UserListDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// PATCH: MANAGE FOLLOW REQUEST
  Future<CommonMessageModel> manageFollowRequest({required dynamic body}) async {
    try {
      Map<String, dynamic> json = await apiClient.patchApiCall(
        endPoint: followRequestUserApiEndPoint,
        isAccessToken: accessToken,
        patchBody: body,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }
}
