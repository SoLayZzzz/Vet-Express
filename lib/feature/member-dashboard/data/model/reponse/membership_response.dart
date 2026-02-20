import '../../../../../models/header.dart';

class MemberShipResponse {
  Header? header;
  Body? body;

  MemberShipResponse({header, body});

  MemberShipResponse.fromJson(Map<String, dynamic> json) {
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
  bool? status;
  String? message;
  List<Data>? data;

  Body({status, message, data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? qrCode;
  String? code;
  String? name;
  String? telephone;
  String? email;
  int? type;
  int? promotionApply;
  double? fixDiscount;

  Data({
    qrCode,
    code,
    name,
    telephone,
    email,
    type,
    promotionApply,
    fixDiscount,
  });

  Data.fromJson(Map<String, dynamic> json) {
    qrCode = json['qrCode'];
    code = json['code'];
    name = json['name'];
    telephone = json['telephone'];
    email = json['email'];
    type = json['type'];
    promotionApply = json['promotionApply'];
    fixDiscount = json['fixDiscount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['qrCode'] = qrCode;
    data['code'] = code;
    data['name'] = name;
    data['telephone'] = telephone;
    data['email'] = email;
    data['type'] = type;
    data['promotionApply'] = promotionApply;
    data['fixDiscount'] = fixDiscount;
    return data;
  }
}
