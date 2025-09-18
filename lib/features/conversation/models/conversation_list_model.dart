import 'conversation_data_model.dart';

class ConversationListModel {
  int? statusCode;
  String? message;
  List<ConversationData>? data;

  ConversationListModel({this.statusCode, this.message, this.data});

  ConversationListModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ConversationData>[];
      json['data'].forEach((v) {
        data!.add(ConversationData.fromJson(v));
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
