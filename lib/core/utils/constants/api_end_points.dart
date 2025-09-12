// Project
import '../services/service.dart';

String baseUrl = "${AppEnvManager.baseUrl}$apiPreFix";

String baseUrlWithoutPrefix = AppEnvManager.baseUrl;

String apiPreFix = "/api";

/// Auth api
String loginApiEndPoint = "/auth/login";

String registerApiEndPoint = "/auth/register";

/// Post Api Routes
String postRoute = '/post';

String postCreateApiEndPoint = "$postRoute/create";

String togglePostLikeApiEndPoint = "$postRoute/like";

String togglePostSaveApiEndPoint = "$postRoute/save";

String toggleRepostApiEndPoint = "$postRoute/repost";

String togglePostArchiveApiEndPoint = "$postRoute/archive";

String getLikedByUserApiEndPoint = "$postRoute/liked-by";

String getLikedPostByUserApiEndPoint = "$postRoute/liked-post";

String getSavedPostByUserApiEndPoint = "$postRoute/saved-post";

String getArchivedPostByUserApiEndPoint = "$postRoute/archived-post";

String getAllReelsApiEndPoint = "$postRoute/reels";

String getUserPostApiEndPoint = "$postRoute/user-post";

/// Comment Api Route
String commentRoute = '/comment';

String createCommentApiEndPoint = "$commentRoute/create";

String getCommentRepliesApiEndPoint = "$commentRoute/replies";

String commentToggleLikeApiEndPoint = '$commentRoute/like';

String pinCommentApiEndPoint = '$commentRoute/pin';

String getUserCommentApiEndPoint = '$commentRoute/user-comment';

/// User Api Route
String userRoute = "/users";

String getFollowersApiEndPoint = "$userRoute/followers";

String getFollowingApiEndPoint = "$userRoute/following";

String followRequestUserApiEndPoint = "$userRoute/follow/requests";

String getDiscoverUserApiEndPoint = "$userRoute/discover";

String toggleFollowUserApiEndPoint = "$userRoute/follow";

String searchUserApiEndPoint = "$userRoute/search";

String updateProfilePictureApiEndPoint = "$userRoute/update-profilePic";
