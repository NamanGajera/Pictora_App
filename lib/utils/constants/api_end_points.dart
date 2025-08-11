import '../services/app_env_manager.dart';

String baseUrl = "${AppEnvManager.baseUrl}$apiPreFix";

String apiPreFix = "/api";

/// Auth api
String loginApiEndPoint = "/auth/login";

String registerApiEndPoint = "/auth/register";

/// Post Api Routes
String postRoute = '/post';

String postCreateApiEndPoint = "$postRoute/create";

String togglePostLikeApiEndPoint = "$postRoute/like";

String togglePostSaveApiEndPoint = "$postRoute/save";

String togglePostArchiveApiEndPoint = "$postRoute/archive";

String getLikedByUserApiEndPoint = "$postRoute/liked-by";

/// Comment Api Route
String commentRoute = '/comment';

String createCommentApiEndPoint = "$commentRoute/create";

String getCommentRepliesApiEndPoint = "$commentRoute/replies";

String commentToggleLikeApiEndPoint = '$commentRoute/like';

String pinCommentApiEndPoint = '$commentRoute/pin';

/// User Api Route
String userRoute = "/users";

String getFollowersApiEndPoint = "$userRoute/followers";

String getFollowingApiEndPoint = "$userRoute/following";

String getFollowRequestUserApiEndPoint = "$userRoute/follow/requests";

String getDiscoverUserApiEndPoint = "$userRoute/discover";

String toggleFollowUserApiEndPoint = "$userRoute/follow";
