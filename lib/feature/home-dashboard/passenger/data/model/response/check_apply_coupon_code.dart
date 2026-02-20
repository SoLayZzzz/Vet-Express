// To parse this JSON data, do
//
//     final promotionCodeResponse = promotionCodeResponseFromJson(jsonString);

import 'dart:convert';

import '../../../../../../models/header.dart';

CheckPromotionCodeResponse promotionCodeResponseFromJson(String str) =>
    CheckPromotionCodeResponse.fromJson(json.decode(str));

String promotionCodeResponseToJson(CheckPromotionCodeResponse data) =>
    json.encode(data.toJson());

class CheckPromotionCodeResponse {
  Header? header;
  Body? body;

  CheckPromotionCodeResponse({this.header, this.body});

  factory CheckPromotionCodeResponse.fromJson(Map<String, dynamic> json) =>
      CheckPromotionCodeResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class Body {
  String? msg;
  int? status;
  int? errorStatus;
  String? balance;
  String? usedTime;

  Body({this.msg, this.status, this.errorStatus, this.balance, this.usedTime});

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    msg: json["msg"],
    status: json["status"],
    errorStatus: json["errorStatus"],
    balance: json["balance"],
    usedTime: json["usedTime"],
  );

  Map<String, dynamic> toJson() => {
    "msg": msg,
    "status": status,
    "errorStatus": errorStatus,
    "balance": balance,
    "usedTime": usedTime,
  };
}
