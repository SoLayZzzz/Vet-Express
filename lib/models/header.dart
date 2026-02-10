import 'pagination.dart';

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;
  String? errorCode;
  String? errorText;
  String? token;
  Pagination? pagination;

  Header({serverTimestamp, result, statusCode, errorCode, errorText, token, pagination});

  Header.fromJson(Map<String, dynamic> json) {
    serverTimestamp = json['serverTimestamp'];
    result = json['result'];
    statusCode = json['statusCode'];
    errorCode = json['errorCode'];
    errorText = json['errorText'];
    token = json['token'];
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serverTimestamp'] = serverTimestamp;
    data['result'] = result;
    data['statusCode'] = statusCode;
    data['errorCode'] = errorCode;
    data['errorText'] = errorText;
    data['token'] = token;
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}
