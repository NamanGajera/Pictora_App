import '../../../model/user_model.dart';

class FollowRequestsModel {
  int? statusCode;
  String? message;
  List<Request>? data;

  FollowRequestsModel({this.statusCode, this.message, this.data});

  FollowRequestsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Request>[];
      json['data'].forEach((v) {
        data!.add(new Request.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Request {
  String? id;
  String? requesterId;
  String? targetId;
  String? status;
  String? createdAt;
  String? updatedAt;
  User? requester;

  Request({this.id, this.requesterId, this.targetId, this.status, this.createdAt, this.updatedAt, this.requester});

  Request.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    requesterId = json['requesterId'];
    targetId = json['targetId'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    requester = json['requester'] != null ? new User.fromJson(json['requester']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['requesterId'] = this.requesterId;
    data['targetId'] = this.targetId;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.requester != null) {
      data['requester'] = this.requester!.toJson();
    }
    return data;
  }
}
