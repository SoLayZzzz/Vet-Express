import '../header.dart';

class AddGoodsResponse {
  Header? header;
  Body? body;

  AddGoodsResponse({header, body});

  AddGoodsResponse.fromJson(Map<String, dynamic> json) {
    header =
    json['header'] != null ?  Header.fromJson(json['header']) : null;
    body = json['body'] != null ?  Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
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
  bool? status;
  String? message;

  Body({status, message});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}