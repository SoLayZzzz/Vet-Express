import 'dart:convert';

import '../../../../../models/header.dart';

GetTicketMemberCardResponse getTicketMemberCardResponseFromJson(String str) =>
    GetTicketMemberCardResponse.fromJson(json.decode(str));

String getTicketMemberCardResponseToJson(GetTicketMemberCardResponse data) =>
    json.encode(data.toJson());

class GetTicketMemberCardResponse {
  Header? header;
  Body? body;

  GetTicketMemberCardResponse({this.header, this.body});

  factory GetTicketMemberCardResponse.fromJson(Map<String, dynamic> json) =>
      GetTicketMemberCardResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class Body {
  bool? status;
  String? message;
  List<Datum>? data;

  Body({this.status, this.message, this.data});

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    status: json["status"],
    message: json["message"],
    data:
        json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? code;
  String? name;
  String? telephone;

  Datum({this.code, this.name, this.telephone});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    code: json["code"],
    name: json["name"],
    telephone: json["telephone"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "telephone": telephone,
  };
}
