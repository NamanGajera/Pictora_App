import '../../../model/user_model.dart';

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
    if (json['mediaData'] != null) {
      mediaData = <MediaData>[];
      json['mediaData'].forEach((v) {
        mediaData!.add(new MediaData.fromJson(v));
      });
    }
    userData = json['userData'] != null ? new User.fromJson(json['userData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['caption'] = this.caption;
    data['likeCount'] = this.likeCount;
    data['commentCount'] = this.commentCount;
    data['shareCount'] = this.shareCount;
    data['saveCount'] = this.saveCount;
    data['viewCount'] = this.viewCount;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['isLiked'] = this.isLiked;
    data['isSaved'] = this.isSaved;
    if (this.mediaData != null) {
      data['mediaData'] = this.mediaData!.map((v) => v.toJson()).toList();
    }
    if (this.userData != null) {
      data['userData'] = this.userData!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postId'] = this.postId;
    data['mediaUrl'] = this.mediaUrl;
    data['thumbnail'] = this.thumbnail;
    data['mediaType'] = this.mediaType;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
