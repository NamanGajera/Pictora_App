import 'package:pictora/features/post/models/post_data.dart';

class PostDataModel {
  int? statusCode;
  String? message;
  List<PostData>? data;
  int? total;

  PostDataModel({this.statusCode, this.message, this.data, this.total});

  PostDataModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PostData>[];
      json['data'].forEach((v) {
        data!.add(PostData.fromJson(v));
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
