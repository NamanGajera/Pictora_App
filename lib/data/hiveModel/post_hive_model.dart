import 'package:hive/hive.dart';

part 'post_hive_model.g.dart';

@HiveType(typeId: 0)
class PostHiveModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? userId;

  @HiveField(2)
  String? caption;

  @HiveField(3)
  int? likeCount;

  @HiveField(4)
  int? commentCount;

  @HiveField(5)
  int? shareCount;

  @HiveField(6)
  int? saveCount;

  @HiveField(7)
  int? viewCount;

  @HiveField(8)
  String? createdAt;

  @HiveField(9)
  String? updatedAt;

  @HiveField(10)
  bool? isLiked;

  @HiveField(11)
  bool? isSaved;

  @HiveField(12)
  List<MediaHiveModel>? mediaData;

  @HiveField(13)
  UserHiveModel? userData;
}

@HiveType(typeId: 1)
class MediaHiveModel {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? postId;

  @HiveField(2)
  String? mediaUrl;

  @HiveField(3)
  String? mediaType;

  @HiveField(4)
  String? createdAt;

  @HiveField(5)
  String? updatedAt;
}

@HiveType(typeId: 2)
class UserHiveModel {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? fullName;

  @HiveField(2)
  String? userName;

  @HiveField(3)
  String? email;

  @HiveField(4)
  ProfileHiveModel? profile;
}

@HiveType(typeId: 3)
class ProfileHiveModel {
  @HiveField(0)
  String? profilePicture;

  @HiveField(1)
  bool? isPrivate;
}
