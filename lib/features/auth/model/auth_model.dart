class AuthModel {
  int? statusCode;
  String? message;
  Data? data;

  AuthModel({this.statusCode, this.message, this.data});

  AuthModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? token;
  User? user;

  Data({this.token, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? fullName;
  String? userName;
  String? email;
  String? password;
  String? createdAt;
  String? updatedAt;
  Profile? profile;

  User({
    this.id,
    this.fullName,
    this.userName,
    this.email,
    this.password,
    this.createdAt,
    this.updatedAt,
    this.profile,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    userName = json['userName'];
    email = json['email'];
    password = json['password'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    profile =
        json['profile'] != null ? Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['userName'] = userName;
    data['email'] = email;
    data['password'] = password;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }
}

class Profile {
  String? profilePicture;
  String? gender;
  bool? isPrivate;

  Profile({this.profilePicture, this.gender, this.isPrivate});

  Profile.fromJson(Map<String, dynamic> json) {
    profilePicture = json['profilePicture'];
    gender = json['gender'];
    isPrivate = json['isPrivate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profilePicture'] = profilePicture;
    data['gender'] = gender;
    data['isPrivate'] = isPrivate;
    return data;
  }
}
