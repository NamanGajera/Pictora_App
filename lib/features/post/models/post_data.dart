// Project
import '../../../core/utils/model/user_model.dart';

class PostData {
  String? id;
  String? userId;
  String? caption;
  int? likeCount;
  int? commentCount;
  int? shareCount;
  int? saveCount;
  int? viewCount;
  String? createdAt;
  String? updatedAt;
  bool? isLiked;
  bool? isSaved;
  bool? isArchived;
  List<MediaData>? mediaData;
  User? userData;
  PostData({
    this.id,
    this.userId,
    this.caption,
    this.likeCount,
    this.commentCount,
    this.shareCount,
    this.saveCount,
    this.viewCount,
    this.createdAt,
    this.updatedAt,
    this.isLiked,
    this.isSaved,
    this.isArchived,
    this.mediaData,
    this.userData,
  });

  PostData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    caption = json['caption'];
    likeCount = json['likeCount'];
    commentCount = json['commentCount'];
    shareCount = json['shareCount'];
    saveCount = json['saveCount'];
    viewCount = json['viewCount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isLiked = json['isLiked'];
    isSaved = json['isSaved'];
    isArchived = json['isArchived'];
    if (json['mediaData'] != null) {
      mediaData = <MediaData>[];
      json['mediaData'].forEach((v) {
        mediaData!.add(MediaData.fromJson(v));
      });
    }
    userData = json['userData'] != null ? User.fromJson(json['userData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['caption'] = caption;
    data['likeCount'] = likeCount;
    data['commentCount'] = commentCount;
    data['shareCount'] = shareCount;
    data['saveCount'] = saveCount;
    data['viewCount'] = viewCount;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['isLiked'] = isLiked;
    data['isSaved'] = isSaved;
    data['isArchived'] = isArchived;
    if (mediaData != null) {
      data['mediaData'] = mediaData!.map((v) => v.toJson()).toList();
    }
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    return data;
  }

  PostData copyWith({
    String? id,
    String? userId,
    String? caption,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? saveCount,
    int? viewCount,
    String? createdAt,
    String? updatedAt,
    bool? isLiked,
    bool? isSaved,
    bool? isArchived,
    List<MediaData>? mediaData,
    User? userData,
  }) {
    return PostData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isArchived: isArchived ?? this.isArchived,
      mediaData: mediaData ?? this.mediaData,
      userData: userData ?? this.userData,
    );
  }
}

class MediaData {
  String? id;
  String? postId;
  String? mediaUrl;
  dynamic thumbnail;
  String? mediaType;
  String? createdAt;
  String? updatedAt;

  MediaData({this.id, this.postId, this.mediaUrl, this.thumbnail, this.mediaType, this.createdAt, this.updatedAt});

  MediaData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    mediaUrl = json['mediaUrl'];
    thumbnail = json['thumbnail'];
    mediaType = json['mediaType'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['postId'] = postId;
    data['mediaUrl'] = mediaUrl;
    data['thumbnail'] = thumbnail;
    data['mediaType'] = mediaType;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
