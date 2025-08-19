import 'package:hive/hive.dart';

part 'user_hive_model.g.dart';

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
