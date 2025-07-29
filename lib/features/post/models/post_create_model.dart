class PostCreateModel {
  int? statusCode;
  String? message;
  Data? data;

  PostCreateModel({this.statusCode, this.message, this.data});

  PostCreateModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  int? likeCount;
  int? commentCount;
  int? shareCount;
  int? saveCount;
  int? viewCount;
  String? userId;
  String? caption;
  String? updatedAt;
  String? createdAt;
  List<MediaData>? mediaData;

  Data(
      {this.id,
      this.likeCount,
      this.commentCount,
      this.shareCount,
      this.saveCount,
      this.viewCount,
      this.userId,
      this.caption,
      this.updatedAt,
      this.createdAt,
      this.mediaData});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    likeCount = json['likeCount'];
    commentCount = json['commentCount'];
    shareCount = json['shareCount'];
    saveCount = json['saveCount'];
    viewCount = json['viewCount'];
    userId = json['userId'];
    caption = json['caption'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
    if (json['mediaData'] != null) {
      mediaData = <MediaData>[];
      json['mediaData'].forEach((v) {
        mediaData!.add(new MediaData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['likeCount'] = this.likeCount;
    data['commentCount'] = this.commentCount;
    data['shareCount'] = this.shareCount;
    data['saveCount'] = this.saveCount;
    data['viewCount'] = this.viewCount;
    data['userId'] = this.userId;
    data['caption'] = this.caption;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    if (this.mediaData != null) {
      data['mediaData'] = this.mediaData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaData {
  String? id;
  String? postId;
  String? mediaUrl;
  Null? thumbnail;
  String? mediaType;
  String? updatedAt;
  String? createdAt;

  MediaData(
      {this.id,
      this.postId,
      this.mediaUrl,
      this.thumbnail,
      this.mediaType,
      this.updatedAt,
      this.createdAt});

  MediaData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    mediaUrl = json['mediaUrl'];
    thumbnail = json['thumbnail'];
    mediaType = json['mediaType'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postId'] = this.postId;
    data['mediaUrl'] = this.mediaUrl;
    data['thumbnail'] = this.thumbnail;
    data['mediaType'] = this.mediaType;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
