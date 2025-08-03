import '../services/app_env_manager.dart';

String baseUrl = "${AppEnvManager.baseUrl}$apiPreFix";

String apiPreFix = "/api";

/// Auth api
String loginApiEndPoint = "/auth/login";

String registerApiEndPoint = "/auth/register";

/// Post api
String postCreateApiEndPoint = "/post/create";

String getAllPostApiEndPoint = "/post";

String getAllCommentApiEndPoint = "/comment";

String createCommentApiEndPoint = "/comment/create";

String getCommentRepliesApiEndPoint = "/comment/replies";
