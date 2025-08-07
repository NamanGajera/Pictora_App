class User {
  String? id;
  String? fullName;
  String? userName;
  String? email;
  Profile? profile;

  User({this.id, this.fullName, this.userName, this.email, this.profile});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    userName = json['userName'];
    email = json['email'];
    profile = json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['userName'] = userName;
    data['email'] = email;
    if (profile != null) {
      data['profile'] = profile!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profilePicture'] = profilePicture;
    return data;
  }
}
