import '../../../core/utils/model/user_model.dart';

class ConversationMemberModel {
  String? id;
  String? conversationId;
  String? userId;
  String? lastReadMessageId;
  int? unreadCount;
  String? lastReadAt;
  String? createdAt;
  String? updatedAt;
  User? userData;

  ConversationMemberModel(
      {this.id,
      this.conversationId,
      this.userId,
      this.lastReadMessageId,
      this.unreadCount,
      this.lastReadAt,
      this.createdAt,
      this.updatedAt,
      this.userData});

  ConversationMemberModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversationId'];
    userId = json['userId'];
    lastReadMessageId = json['lastReadMessageId'];
    unreadCount = json['unreadCount'];
    lastReadAt = json['lastReadAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userData = json['userData'] != null ? User.fromJson(json['userData']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversationId'] = conversationId;
    data['userId'] = userId;
    data['lastReadMessageId'] = lastReadMessageId;
    data['unreadCount'] = unreadCount;
    data['lastReadAt'] = lastReadAt;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    return data;
  }

  ConversationMemberModel copyWith({
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
    return ConversationMemberModel(
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
