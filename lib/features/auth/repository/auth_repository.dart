// Project
import '../../../core/network/api_client.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/utils/helper/helper.dart';
import '../model/auth_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

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
}
