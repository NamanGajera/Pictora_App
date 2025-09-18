import 'conversation_message_data_model.dart';

class ConversationMessagesListModel {
  int? statusCode;
  String? message;
  List<ConversationMessage>? data;
  int? total;

  ConversationMessagesListModel({this.statusCode, this.message, this.data, this.total});

  ConversationMessagesListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ConversationMessage>[];
      json['data'].forEach((v) {
        data!.add(ConversationMessage.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}
