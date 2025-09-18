import 'package:pictora/core/utils/model/user_model.dart';

import '../../../core/utils/constants/constants.dart';
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
  MessageStatus? messageStatus;
  User? senderData;
  PostData? postData;
  List<MessageAttachments>? attachments;
  ConversationMessage? repliedMessageData;

  ConversationMessage({
    this.id,
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
    this.repliedMessageData,
    this.messageStatus = MessageStatus.sent,
  });

  ConversationMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversationId'];
    senderId = json['senderId'];
    message = json['message'];
    postId = json['postId'];
    replyToMessageId = json['replyToMessageId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    senderData = json['senderData'] != null ? User.fromJson(json['senderData']) : null;
    postData = json['postData'] != null ? PostData.fromJson(json['postData']) : null;
    if (json['attachments'] != null) {
      attachments = <MessageAttachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(MessageAttachments.fromJson(v));
      });
    }
    repliedMessageData = json['repliedMessageData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversationId'] = conversationId;
    data['senderId'] = senderId;
    data['message'] = message;
    data['postId'] = postId;
    data['replyToMessageId'] = replyToMessageId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['messageStatus'] = messageStatus;
    if (senderData != null) {
      data['senderData'] = senderData!.toJson();
    }
    if (postData != null) {
      data['postData'] = postData!.toJson();
    }
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    data['repliedMessageData'] = repliedMessageData;
    return data;
  }

  ConversationMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? message,
    String? postId,
    String? replyToMessageId,
    String? createdAt,
    String? updatedAt,
    MessageStatus? messageStatus,
    User? senderData,
    PostData? postData,
    List<MessageAttachments>? attachments,
    ConversationMessage? repliedMessageData,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      postId: postId ?? this.postId,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageStatus: messageStatus ?? this.messageStatus,
      senderData: senderData ?? this.senderData,
      postData: postData ?? this.postData,
      attachments: attachments ?? this.attachments,
      repliedMessageData: repliedMessageData ?? this.repliedMessageData,
    );
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['messageId'] = messageId;
    data['url'] = url;
    data['thumbnailUrl'] = thumbnailUrl;
    data['publicId'] = publicId;
    data['metadata'] = metadata;
    data['type'] = type;
    return data;
  }

  MessageAttachments copyWith({
    String? id,
    String? messageId,
    String? url,
    String? thumbnailUrl,
    String? publicId,
    String? metadata,
    String? type,
  }) {
    return MessageAttachments(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publicId: publicId ?? this.publicId,
      metadata: metadata ?? this.metadata,
      type: type ?? this.type,
    );
  }
}
