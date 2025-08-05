import '../services/app_env_manager.dart';

String baseUrl = "${AppEnvManager.baseUrl}$apiPreFix";

String apiPreFix = "/api";

/// Auth api
String loginApiEndPoint = "/auth/login";

String registerApiEndPoint = "/auth/register";

/// Post Api Routes
String postRoute = '/post';

String postCreateApiEndPoint = "$postRoute/create";

/// Comment Api Route
String commentRoute = '/comment';

String createCommentApiEndPoint = "$commentRoute/create";

String getCommentRepliesApiEndPoint = "$commentRoute/replies";

String commentToggleLikeApiEndPoint = '$commentRoute/like';

String pinCommentApiEndPoint = '$commentRoute/pin';
