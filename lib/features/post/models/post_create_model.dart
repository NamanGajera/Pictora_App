import 'package:pictora/features/post/models/post_data.dart';

class PostCreateModel {
  int? statusCode;
  String? message;
  PostData? data;

  PostCreateModel({this.statusCode, this.message, this.data});

  PostCreateModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new PostData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
