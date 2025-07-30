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
  UserData? userData;
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
    userData = json['userData'] != null
        ? new UserData.fromJson(json['userData'])
        : null;
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
}

class MediaData {
  String? id;
  String? postId;
  String? mediaUrl;
  dynamic thumbnail;
  String? mediaType;
  String? createdAt;
  String? updatedAt;

  MediaData(
      {this.id,
      this.postId,
      this.mediaUrl,
      this.thumbnail,
      this.mediaType,
      this.createdAt,
      this.updatedAt});

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

class UserData {
  String? id;
  String? fullName;
  String? userName;
  String? email;
  Profile? profile;

  UserData({this.id, this.fullName, this.userName, this.email, this.profile});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    userName = json['userName'];
    email = json['email'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fullName'] = this.fullName;
    data['userName'] = this.userName;
    data['email'] = this.email;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  dynamic profilePicture;

  Profile({this.profilePicture});

  Profile.fromJson(Map<String, dynamic> json) {
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profilePicture'] = this.profilePicture;
    return data;
  }
}
