import 'conversation_member_model.dart';
import 'conversation_message_data_model.dart';

class ConversationData {
  String? id;
  String? type;
  String? title;
  int? unreadCount;
  Metadata? metadata;
  ConversationMessage? lastMessage;
  List<ConversationMemberModel>? members;
  String? updatedAt;
  bool? isTyping;
  String? typingUserId;

  ConversationData({
    this.id,
    this.type,
    this.title,
    this.lastMessage,
    this.metadata,
    this.members,
    this.updatedAt,
    this.unreadCount,
    this.isTyping = false,
    this.typingUserId,
  });

  ConversationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    unreadCount = json['unreadCount'];
    metadata = json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    lastMessage = json['lastMessage'] != null ? ConversationMessage.fromJson(json['lastMessage']) : null;
    if (json['members'] != null) {
      members = <ConversationMemberModel>[];
      json['members'].forEach((v) {
        members!.add(ConversationMemberModel.fromJson(v));
      });
    }
    updatedAt = json['updatedAt'];
    isTyping = json['isTyping'];
    typingUserId = json['typingUserId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    if (lastMessage != null) {
      data['lastMessage'] = lastMessage!.toJson();
    }
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    data['updatedAt'] = updatedAt;
    data['unreadCount'] = unreadCount;
    data['typingUserId'] = typingUserId;
    data['isTyping'] = isTyping;
    return data;
  }

  ConversationData copyWith({
    String? id,
    String? type,
    String? title,
    int? unreadCount,
    ConversationMessage? lastMessage,
    List<ConversationMemberModel>? members,
    String? updatedAt,
    bool? isTyping,
    String? typingUserId,
  }) {
    return ConversationData(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      members: members ?? this.members,
      updatedAt: updatedAt ?? this.updatedAt,
      isTyping: isTyping ?? this.isTyping,
      typingUserId: typingUserId ?? this.typingUserId,
    );
  }
}

class Metadata {
  GroupImage? groupImage;

  Metadata({this.groupImage});

  Metadata.fromJson(Map<String, dynamic> json) {
    groupImage = json['groupImage'] != null ? GroupImage.fromJson(json['groupImage']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (groupImage != null) {
      data['groupImage'] = groupImage!.toJson();
    }
    return data;
  }
}

class GroupImage {
  String? url;
  String? publicId;

  GroupImage({this.url, this.publicId});

  GroupImage.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    publicId = json['publicId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['publicId'] = publicId;
    return data;
  }
}
