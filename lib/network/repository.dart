import 'api_client.dart';

class Repository {
  final ApiClient apiClient;

  Repository(this.apiClient);

  /// ~~~~~~~~~~~~~~~LOGIN AND SIGN UP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // /// POST: LOGIN
  // Future<LoginModel> postLogin(dynamic body) async {
  //   try {
  //     Map<String, dynamic> json = await apiClient.postApiCall(
  //       baseUrl,
  //       logInAPIEnd,
  //       body,
  //     );
  //     LoginModel loginScreenRes = LoginModel.fromJson(json);
  //     return loginScreenRes;
  //   } on CustomException {
  //     rethrow;
  //   }
  // }
}
