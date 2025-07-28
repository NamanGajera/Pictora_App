import 'package:pictora/features/auth/model/auth_model.dart';
import 'package:pictora/utils/constants/api_end_points.dart';

import 'api_client.dart';
import 'custom_exception.dart';

class Repository {
  final ApiClient apiClient;

  Repository(this.apiClient);

  /// POST: LOGIN
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
