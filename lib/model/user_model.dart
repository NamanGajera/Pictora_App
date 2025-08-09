class User {
  String? id;
  String? userName;
  String? fullName;
  String? email;
  Profile? profile;
  Counts? counts;
  bool? isFollowed;
  String? followRequestStatus;
  bool? showFollowBack;

  User({
    this.id,
    this.userName,
    this.fullName,
    this.email,
    this.profile,
    this.counts,
    this.isFollowed,
    this.followRequestStatus,
    this.showFollowBack,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['userName'];
    fullName = json['fullName'];
    email = json['email'];
    profile = json['profile'] != null ? Profile.fromJson(json['profile']) : null;
    counts = json['counts'] != null ? Counts.fromJson(json['counts']) : null;
    isFollowed = json['isFollowed'];
    followRequestStatus = json['followRequestStatus'];
    showFollowBack = json['showFollowBack'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userName'] = userName;
    data['fullName'] = fullName;
    data['email'] = email;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    if (counts != null) {
      data['counts'] = counts!.toJson();
    }
    data['isFollowed'] = isFollowed;
    data['followRequestStatus'] = followRequestStatus;
    data['showFollowBack'] = showFollowBack;
    return data;
  }
}

class Profile {
  String? profilePicture;
  String? bio;
  String? dob;
  String? gender;
  bool? isPrivate;
  String? location;

  Profile({
    this.profilePicture,
    this.bio,
    this.dob,
    this.gender,
    this.isPrivate,
    this.location,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    profilePicture = json['profilePicture'];
    bio = json['bio'];
    dob = json['dob'];
    gender = json['gender'];
    isPrivate = json['isPrivate'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profilePicture'] = profilePicture;
    data['bio'] = bio;
    data['dob'] = dob;
    data['gender'] = gender;
    data['isPrivate'] = isPrivate;
    data['location'] = location;
    return data;
  }
}

class Counts {
  int? followerCount;
  int? followingCount;
  int? postCount;

  Counts({this.followerCount, this.followingCount, this.postCount});

  Counts.fromJson(Map<String, dynamic> json) {
    followerCount = json['followerCount'];
    followingCount = json['followingCount'];
    postCount = json['postCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['followerCount'] = followerCount;
    data['followingCount'] = followingCount;
    data['postCount'] = postCount;
    return data;
  }
}
