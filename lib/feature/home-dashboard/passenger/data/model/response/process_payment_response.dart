import '../../../../../../models/header.dart';

class PaymentResponse {
  Header? header;
  Body? body;

  PaymentResponse({this.header, this.body});

  PaymentResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (header != null) {
      data['header'] = header!.toJson();
    }
    if (body != null) {
      data['body'] = body!.toJson();
    }
    return data;
  }
}

class Body {
  String? msg;
  int? status;
  String? token;

  Body({this.msg, this.status, this.token});

  Body.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    status = json['status'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['status'] = status;
    data['token'] = token;
    return data;
  }
}
