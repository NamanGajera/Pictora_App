import '../../features/post/models/post_data.dart';
import '../model/user_model.dart';
import 'post_hive_model.dart';

extension PostMapper on PostData {
  PostHiveModel toHiveModel() {
    return PostHiveModel()
      ..id = id
      ..userId = userId
      ..caption = caption
      ..likeCount = likeCount
      ..commentCount = commentCount
      ..shareCount = shareCount
      ..saveCount = saveCount
      ..viewCount = viewCount
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..isLiked = isLiked
      ..isSaved = isSaved
      ..mediaData = mediaData
          ?.map((m) => MediaHiveModel()
            ..id = m.id
            ..postId = m.postId
            ..mediaUrl = m.mediaUrl
            ..mediaType = m.mediaType
            ..createdAt = m.createdAt
            ..updatedAt = m.updatedAt)
          .toList()
      ..userData = userData != null
          ? (UserHiveModel()
            ..id = userData!.id
            ..fullName = userData!.fullName
            ..userName = userData!.userName
            ..email = userData!.email
            ..profile = userData!.profile != null
                ? (ProfileHiveModel()
                  ..profilePicture = userData!.profile!.profilePicture
                  ..isPrivate = userData!.profile!.isPrivate)
                : null)
          : null;
  }
}

extension HiveMapper on PostHiveModel {
  PostData toEntity() {
    return PostData(
      id: id,
      userId: userId,
      caption: caption,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      saveCount: saveCount,
      viewCount: viewCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isLiked: isLiked,
      isSaved: isSaved,
      mediaData: mediaData
          ?.map((m) => MediaData(
                id: m.id,
                postId: m.postId,
                mediaUrl: m.mediaUrl,
                mediaType: m.mediaType,
                createdAt: m.createdAt,
                updatedAt: m.updatedAt,
              ))
          .toList(),
      userData: userData != null
          ? User(
              id: userData!.id,
              fullName: userData!.fullName,
              userName: userData!.userName,
              email: userData!.email,
              profile: userData!.profile != null
                  ? Profile(
                      profilePicture: userData!.profile!.profilePicture,
                      isPrivate: userData!.profile!.isPrivate ?? false,
                    )
                  : null,
            )
          : null,
    );
  }
}
