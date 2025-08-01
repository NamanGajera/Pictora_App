class AuthModel {
  int? statusCode;
  String? message;

  AuthModel({
    this.statusCode,
    this.message,
  });

  AuthModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;

    return data;
  }
}
