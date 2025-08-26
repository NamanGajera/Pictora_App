// Project
import '../../../core/network/api_client.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/helper/helper.dart';
import '../../../core/utils/model/user_list_data_model.dart';

class SearchRepository {
  ApiClient apiClient;
  SearchRepository(this.apiClient);

  Future<UserListDataModel> searchUsers(dynamic body) async {
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
}
