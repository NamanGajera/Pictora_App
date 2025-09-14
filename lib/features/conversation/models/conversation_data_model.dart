import 'package:pictora/core/utils/model/user_model.dart';

class ConversationData {
  String? id;
  String? type;
  String? title;
  LastMessage? lastMessage;
  List<OtherUser>? otherUser;
  String? updatedAt;

  ConversationData({
    this.id,
    this.type,
    this.title,
    this.lastMessage,
    this.otherUser,
    this.updatedAt,
  });

  ConversationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    lastMessage = json['lastMessage'] != null ? new LastMessage.fromJson(json['lastMessage']) : null;
    if (json['otherUser'] != null) {
      otherUser = <OtherUser>[];
      json['otherUser'].forEach((v) {
        otherUser!.add(new OtherUser.fromJson(v));
      });
    }
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['title'] = this.title;
    if (this.lastMessage != null) {
      data['lastMessage'] = this.lastMessage!.toJson();
    }
    if (this.otherUser != null) {
      data['otherUser'] = this.otherUser!.map((v) => v.toJson()).toList();
    }
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class LastMessage {
  String? id;
  String? conversationId;
  String? senderId;
  String? message;
  String? postId;
  String? replyToMessageId;
  String? createdAt;
  String? updatedAt;
  List<Null>? attachments;

  LastMessage(
      {this.id,
      this.conversationId,
      this.senderId,
      this.message,
      this.postId,
      this.replyToMessageId,
      this.createdAt,
      this.updatedAt,
      this.attachments});

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversationId'];
    senderId = json['senderId'];
    message = json['message'];
    postId = json['postId'];
    replyToMessageId = json['replyToMessageId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['conversationId'] = this.conversationId;
    data['senderId'] = this.senderId;
    data['message'] = this.message;
    data['postId'] = this.postId;
    data['replyToMessageId'] = this.replyToMessageId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }
}

class OtherUser {
  String? id;
  String? conversationId;
  String? userId;
  String? lastReadMessageId;
  int? unreadCount;
  String? lastReadAt;
  String? createdAt;
  String? updatedAt;
  User? userData;

  OtherUser(
      {this.id,
      this.conversationId,
      this.userId,
      this.lastReadMessageId,
      this.unreadCount,
      this.lastReadAt,
      this.createdAt,
      this.updatedAt,
      this.userData});

  OtherUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversationId'];
    userId = json['userId'];
    lastReadMessageId = json['lastReadMessageId'];
    unreadCount = json['unreadCount'];
    lastReadAt = json['lastReadAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userData = json['userData'] != null ? new User.fromJson(json['userData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['conversationId'] = this.conversationId;
    data['userId'] = this.userId;
    data['lastReadMessageId'] = this.lastReadMessageId;
    data['unreadCount'] = this.unreadCount;
    data['lastReadAt'] = this.lastReadAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.userData != null) {
      data['userData'] = this.userData!.toJson();
    }
    return data;
  }
}
