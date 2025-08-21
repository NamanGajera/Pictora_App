import '../../../core/utils/model/user_model.dart';

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
        data!.add(Request.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
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
    requester = json['requester'] != null ? User.fromJson(json['requester']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['requesterId'] = requesterId;
    data['targetId'] = targetId;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (requester != null) {
      data['requester'] = requester!.toJson();
    }
    return data;
  }

  Request copyWith({
    String? id,
    String? requesterId,
    String? targetId,
    String? status,
    String? createdAt,
    String? updatedAt,
    User? requester,
  }) {
    return Request(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      targetId: targetId ?? this.targetId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requester: requester ?? this.requester,
    );
  }
}
