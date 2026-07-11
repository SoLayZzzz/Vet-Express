import 'dart:convert';

ChoosePaymentResponse choosePaymentResponseFromJson(String str) =>
    ChoosePaymentResponse.fromJson(json.decode(str));

String choosePaymentResponseToJson(ChoosePaymentResponse data) =>
    json.encode(data.toJson());

class ChoosePaymentResponse {
  Header? header;
  Body? body;

  ChoosePaymentResponse({this.header, this.body});

  ChoosePaymentResponse.fromJson(Map<String, dynamic> json) {
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

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({this.serverTimestamp, this.result, this.statusCode});

  Header.fromJson(Map<String, dynamic> json) {
    serverTimestamp = json['serverTimestamp'];
    result = json['result'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serverTimestamp'] = serverTimestamp;
    data['result'] = result;
    data['statusCode'] = statusCode;
    return data;
  }
}

class Body {
  bool? status;
  String? message;
  List<Datum>? data;

  Body({this.status, this.message, this.data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Datum>[];
      json['data'].forEach((v) {
        data!.add(Datum.fromJson(v));
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

class Datum {
  String name;
  int status;

  Datum({required this.name, required this.status});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json['name'] ?? '',
        status: json['status'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status,
      };
}
