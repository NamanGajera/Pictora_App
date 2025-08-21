// Project
import '../../../utils/model/user_model.dart';
import 'user_hive_model.dart';

extension UserMapper on User {
  UserHiveModel toHiveModel() {
    return UserHiveModel()
      ..id = id
      ..fullName = fullName
      ..userName = userName
      ..email = email
      ..profile = profile != null
          ? (ProfileHiveModel()
            ..profilePicture = profile!.profilePicture
            ..isPrivate = profile!.isPrivate)
          : null;
  }
}

extension HiveMapper on UserHiveModel {
  User toEntity() {
    return User(
      id: id,
      fullName: fullName,
      userName: userName,
      email: email,
      profile: profile != null
          ? Profile(
              profilePicture: profile!.profilePicture,
              isPrivate: profile!.isPrivate ?? false,
            )
          : null,
    );
  }
}
