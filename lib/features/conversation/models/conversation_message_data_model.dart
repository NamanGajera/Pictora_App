import 'package:pictora/core/utils/model/user_model.dart';

import '../../post/models/post_data.dart';

class ConversationMessage {
  String? id;
  String? conversationId;
  String? senderId;
  String? message;
  String? postId;
  String? replyToMessageId;
  String? createdAt;
  String? updatedAt;
  User? senderData;
  PostData? postData;
  List<MessageAttachments>? attachments;
  ConversationMessage? repliedMessageData;

  ConversationMessage(
      {this.id,
      this.conversationId,
      this.senderId,
      this.message,
      this.postId,
      this.replyToMessageId,
      this.createdAt,
      this.updatedAt,
      this.senderData,
      this.postData,
      this.attachments,
      this.repliedMessageData});

  ConversationMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversationId'];
    senderId = json['senderId'];
    message = json['message'];
    postId = json['postId'];
    replyToMessageId = json['replyToMessageId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    senderData = json['senderData'] != null ? new User.fromJson(json['senderData']) : null;
    postData = json['postData'] != null ? new PostData.fromJson(json['postData']) : null;
    if (json['attachments'] != null) {
      attachments = <MessageAttachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(new MessageAttachments.fromJson(v));
      });
    }
    repliedMessageData = json['repliedMessageData'];
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
    if (this.senderData != null) {
      data['senderData'] = this.senderData!.toJson();
    }
    if (this.postData != null) {
      data['postData'] = this.postData!.toJson();
    }
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    data['repliedMessageData'] = this.repliedMessageData;
    return data;
  }
}

class MessageAttachments {
  String? id;
  String? messageId;
  String? url;
  String? thumbnailUrl;
  String? publicId;
  String? metadata;
  String? type;

  MessageAttachments({this.id, this.messageId, this.url, this.thumbnailUrl, this.publicId, this.metadata, this.type});

  MessageAttachments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageId = json['messageId'];
    url = json['url'];
    thumbnailUrl = json['thumbnailUrl'];
    publicId = json['publicId'];
    metadata = json['metadata'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['messageId'] = this.messageId;
    data['url'] = this.url;
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['publicId'] = this.publicId;
    data['metadata'] = this.metadata;
    data['type'] = this.type;
    return data;
  }
}
