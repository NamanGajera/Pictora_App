import '../../../core/network/api_client.dart';
import '../../../core/utils/helper/helper.dart';
import '../../../core/utils/model/user_list_data_model.dart';
import '../conversation.dart';
import 'package:pictora/core/utils/constants/constants.dart';

class ConversationRepository {
  ApiClient apiClient;
  ConversationRepository(this.apiClient);

  /// GET: GET CONVERSATIONS
  Future<ConversationListModel> getConversationsData() async {
    try {
      final Map<String, dynamic> json = await apiClient.getApiCall(
        endPoint: conversationRoute,
        isAccessToken: accessToken,
      );

      return ConversationListModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET CONVERSATION MESSAGES
  Future<ConversationMessagesListModel> getConversationMessagesData({required Map<String, dynamic> postBody}) async {
    try {
      final Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: getConversationMessagesApiEndPoint,
        isAccessToken: accessToken,
        postBody: postBody,
      );

      return ConversationMessagesListModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: CREATE MESSAGE
  Future<ConversationMessage> createMessage({dynamic fields, dynamic fileFields}) async {
    try {
      Map<String, dynamic> json = await apiClient.multipartPostApiCall(
        endPoint: createConversationMessagesApiEndPoint,
        authorizationToken: accessToken,
        fields: fields,
        fileFields: fileFields,
      );
      return ConversationMessage.fromJson(json['data']);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: GET USER LIST
  Future<UserListDataModel> getAllUserList(dynamic body) async {
    try {
      Map<String, dynamic> json = await apiClient.postApiCall(
        endPoint: searchUserApiEndPoint,
        postBody: body,
        isAccessToken: accessToken,
      );

      return UserListDataModel.fromJson(json);
    } on CustomException {
      rethrow;
    }
  }

  /// POST: CREATE CONVERSATION
  Future<ConversationData> createConversation({dynamic fields, dynamic fileFields}) async {
    try {
      Map<String, dynamic> json = await apiClient.multipartPostApiCall(
        endPoint: createConversationApiEndPoint,
        fields: fields,
        fileFields: fileFields,
        authorizationToken: accessToken,
      );

      return ConversationData.fromJson(json["data"]);
    } on CustomException {
      rethrow;
    }
  }
}
