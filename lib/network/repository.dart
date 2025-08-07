import 'package:pictora/features/auth/model/auth_model.dart';
import 'package:pictora/features/post/models/post_comment_data_model.dart';
import 'package:pictora/features/post/models/post_create_model.dart';
import 'package:pictora/features/post/models/post_data_model.dart';
import 'package:pictora/model/common_message_model.dart';
import 'package:pictora/utils/constants/api_end_points.dart';
import 'package:pictora/utils/constants/constants.dart';

import 'api_client.dart';
import 'custom_exception.dart';

class Repository {
  final ApiClient apiClient;

  Repository(this.apiClient);

  /// POST: REGISTER
  Future<AuthModel> registerUser(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: registerApiEndPoint,
        postBody: body,
      );
      return AuthModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: LOGIN
  Future<AuthModel> login(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: loginApiEndPoint,
        postBody: body,
      );
      return AuthModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: CREATE POST
  Future<PostCreateModel> createPost({dynamic fields, dynamic fileFields}) async {
    try {
      Map<String, dynamic> json = await apiClient.multipartPostApiCall(
        baseUrl: baseUrl,
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

  Future<CommonMessageModel> deleteComment(String commentId) async {
    try {
      Map<String, dynamic> json = await apiClient.deleteAPICalls(
        baseUrl: baseUrl,
        endPoint: '$commentRoute/$commentId',
        isAccessToken: accessToken,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

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

  Future<CommonMessageModel> deletePost(String postId) async {
    try {
      Map<String, dynamic> json = await apiClient.deleteAPICalls(
        baseUrl: baseUrl,
        endPoint: '$postRoute/$postId',
        isAccessToken: accessToken,
      );

      return CommonMessageModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

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
}
