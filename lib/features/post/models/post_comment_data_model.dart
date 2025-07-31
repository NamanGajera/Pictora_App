class PostCommentDataModel {
  int? statusCode;
  String? message;
  List<CommentData>? data;
  int? total;

  PostCommentDataModel({this.statusCode, this.message, this.data, this.total});

  PostCommentDataModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CommentData>[];
      json['data'].forEach((v) {
        data!.add(new CommentData.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class CommentData {
  String? id;
  String? postId;
  String? userId;
  String? comment;
  dynamic parentCommentId;
  int? likeCount;
  bool? isPinned;
  String? createdAt;
  String? updatedAt;
  int? repliesCount;
  User? user;
  bool? isLiked;

  CommentData({this.id, this.postId, this.userId, this.comment, this.parentCommentId, this.likeCount, this.isPinned, this.createdAt, this.updatedAt, this.repliesCount, this.user, this.isLiked});

  CommentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    userId = json['userId'];
    comment = json['comment'];
    parentCommentId = json['parentCommentId'];
    likeCount = json['likeCount'];
    isPinned = json['isPinned'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    repliesCount = json['repliesCount'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    isLiked = json['isLiked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postId'] = this.postId;
    data['userId'] = this.userId;
    data['comment'] = this.comment;
    data['parentCommentId'] = this.parentCommentId;
    data['likeCount'] = this.likeCount;
    data['isPinned'] = this.isPinned;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['repliesCount'] = this.repliesCount;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['isLiked'] = this.isLiked;
    return data;
  }
}

class User {
  String? id;
  String? username;
  Profile? profile;

  User({this.id, this.username, this.profile});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    profile = json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  String? id;
  String? userId;
  dynamic profilePicture;

  Profile({this.id, this.userId, this.profilePicture});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    profilePicture = json['profilePicture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['profilePicture'] = this.profilePicture;
    return data;
  }
}
