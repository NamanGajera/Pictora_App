import '../Constants/enums.dart';

class AppEnvManager {
  static AppEnv currentEnv = AppEnv.local;

  static String? _customLocalUrl;

  static void setLocalBaseUrl(String url) {
    _customLocalUrl = url;
  }

  static String get baseUrl {
    switch (currentEnv) {
      case AppEnv.local:
        return _customLocalUrl ?? "http://192.168.1.153:5001";
    }
  }

  static String get baseImageUrl => baseUrl;
}
