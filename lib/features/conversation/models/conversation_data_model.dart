import 'package:pictora/core/utils/model/user_model.dart';

import 'conversation_message_data_model.dart';

class ConversationData {
  String? id;
  String? type;
  String? title;
  int? unreadCount;
  ConversationMessage? lastMessage;
  List<OtherUser>? otherUser;
  String? updatedAt;

  ConversationData({
    this.id,
    this.type,
    this.title,
    this.lastMessage,
    this.otherUser,
    this.updatedAt,
    this.unreadCount,
  });

  ConversationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    unreadCount = json['unreadCount'];
    lastMessage = json['lastMessage'] != null ? new ConversationMessage.fromJson(json['lastMessage']) : null;
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
    data['unreadCount'] = this.unreadCount;
    return data;
  }

  ConversationData copyWith({
    String? id,
    String? type,
    String? title,
    int? unreadCount,
    ConversationMessage? lastMessage,
    List<OtherUser>? otherUser,
    String? updatedAt,
  }) {
    return ConversationData(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      otherUser: otherUser ?? this.otherUser,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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

  OtherUser copyWith({
    String? id,
    String? conversationId,
    String? userId,
    String? lastReadMessageId,
    int? unreadCount,
    String? lastReadAt,
    String? createdAt,
    String? updatedAt,
    User? userData,
  }) {
    return OtherUser(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      lastReadMessageId: lastReadMessageId ?? this.lastReadMessageId,
      unreadCount: unreadCount ?? this.unreadCount,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userData: userData ?? this.userData,
    );
  }
}
