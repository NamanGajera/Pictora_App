// Project
import '../../../core/network/api_client.dart';
import '../../../core/utils/helper/helper.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/model/common_message_model.dart';
import '../../../core/utils/model/user_list_data_model.dart';
import '../models/models.dart';

class PostRepository {
  ApiClient apiClient;

  PostRepository(this.apiClient);

  /// POST: CREATE POST
  Future<PostCreateModel> createPost({dynamic fields, dynamic fileFields}) async {
    try {
      Map<String, dynamic> json = await apiClient.multipartPostApiCall(
        endPoint: postCreateApiEndPoint,
        authorizationToken: accessToken,
        fields: fields,
        fileFields: fileFields,
      );
      return PostCreateModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET ALL POST
  Future<PostDataModel> getAllPost(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: postRoute,
        isAccessToken: accessToken,
        postBody: body,
      );

      return PostDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET ALL POST COMMENTS
  Future<PostCommentDataModel> getPostComment(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: commentRoute,
        isAccessToken: accessToken,
        postBody: body,
      );

      return PostCommentDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: CREATE COMMENT
  Future<CommentData> createComment(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: createCommentApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return CommentData.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET COMMENT REPLIES
  Future<PostCommentDataModel> getCommentReplies(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: getCommentRepliesApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return PostCommentDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: TOGGLE COMMENT LIKE
  Future<CommonMessageModel> toggleCommentLike(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: commentToggleLikeApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// DELETE: DELETE COMMENT
  Future<CommonMessageModel> deleteComment(String commentId) async {
    try {
      Map<String, dynamic> json = await apiClient.deleteAPICalls(
        endPoint: '$commentRoute/$commentId',
        isAccessToken: accessToken,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: TOGGLE POST LIKE
  Future<CommonMessageModel> togglePostLike(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: togglePostLikeApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: TOGGLE POST SAVE
  Future<CommonMessageModel> togglePostSave(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: togglePostSaveApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// DELETE: DELETE POST
  Future<CommonMessageModel> deletePost(String postId) async {
    try {
      Map<String, dynamic> json = await apiClient.deleteAPICalls(
        endPoint: '$postRoute/$postId',
        isAccessToken: accessToken,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: TOGGLE POST ARCHIVE
  Future<CommonMessageModel> toggleArchivePost(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: togglePostArchiveApiEndPoint,
        isAccessToken: accessToken,
        postBody: body,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET LIKED BY USER
  Future<UserListDataModel> getLikedByUser({required String postId, required dynamic body}) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: "$getLikedByUserApiEndPoint/$postId",
        isAccessToken: accessToken,
        postBody: body,
      );

      return UserListDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }
}
