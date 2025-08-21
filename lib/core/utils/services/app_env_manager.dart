// Project
import '../constants/constants.dart';

class AppEnvManager {
  static AppEnv currentEnv = AppEnv.local;

  static String? _customLocalUrl;

  static void setLocalBaseUrl(String url) {
    _customLocalUrl = url;
  }

  static String get baseUrl {
    switch (currentEnv) {
      case AppEnv.local:
        return _customLocalUrl ?? "http://192.168.1.110:5000";
    }
  }

  static String get baseImageUrl => baseUrl;
}
