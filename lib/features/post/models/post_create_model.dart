import 'package:pictora/features/post/models/post_data.dart';

class PostCreateModel {
  int? statusCode;
  String? message;
  PostData? data;

  PostCreateModel({this.statusCode, this.message, this.data});

  PostCreateModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? PostData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
