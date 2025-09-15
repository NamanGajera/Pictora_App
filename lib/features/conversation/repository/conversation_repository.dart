import '../../../core/network/api_client.dart';
import '../../../core/utils/helper/helper.dart';
import '../conversation.dart';
import 'package:pictora/core/utils/constants/constants.dart';

class ConversationRepository {
  ApiClient apiClient;
  ConversationRepository(this.apiClient);

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
}
