import '../header.dart';

class SavingPointResponse {
  Header? header;
  Body? body;

  SavingPointResponse({header, body});

  SavingPointResponse.fromJson(Map<String, dynamic> json) {
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
  List<Data>? data;

  Body({status, message, data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add( Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? totalTransfer;
  String? totalAmount;
  String? totalPoint;

  Data({totalTransfer, totalAmount, totalPoint});

  Data.fromJson(Map<String, dynamic> json) {
    totalTransfer = json['totalTransfer'];
    totalAmount = json['totalAmount'];
    totalPoint = json['totalPoint'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['totalTransfer'] = totalTransfer;
    data['totalAmount'] = totalAmount;
    data['totalPoint'] = totalPoint;
    return data;
  }
}