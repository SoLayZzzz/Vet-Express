// To parse this JSON data, do
//
//     final evStationListResponse = evStationListResponseFromJson(jsonString);

import 'dart:convert';

EvStationListResponse evStationListResponseFromJson(String str) =>
    EvStationListResponse.fromJson(json.decode(str));

String evStationListResponseToJson(EvStationListResponse data) =>
    json.encode(data.toJson());

class EvStationListResponse {
  Header? header;
  EvStationListBody? body;

  EvStationListResponse({this.header, this.body});

  factory EvStationListResponse.fromJson(Map<String, dynamic> json) =>
      EvStationListResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null
                ? null
                : EvStationListBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvStationListBody {
  bool? status;
  String? message;
  List<EvStationListDatum>? data;

  EvStationListBody({this.status, this.message, this.data});

  factory EvStationListBody.fromJson(Map<String, dynamic> json) =>
      EvStationListBody(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<EvStationListDatum>.from(
                  json["data"]!.map((x) => EvStationListDatum.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class EvStationListDatum {
  int? id;
  String? code;
  int? companyId;
  int? provinceId;
  String? name;
  double? pricePerKwh;
  String? phoneNumber;
  String? description;
  String? address;
  String? imageUrl;
  String? imageName;
  String? lats;
  String? longs;
  bool? isFavorite;
  int? totalCharger;
  int? totalChargerAvailable;
  String? value;
  List<EvStationGunInform>? gunInform;

  EvStationListDatum({
    this.id,
    this.code,
    this.companyId,
    this.provinceId,
    this.name,
    this.pricePerKwh,
    this.phoneNumber,
    this.description,
    this.address,
    this.imageUrl,
    this.imageName,
    this.lats,
    this.longs,
    this.isFavorite,
    this.totalCharger,
    this.totalChargerAvailable,
    this.value,
    this.gunInform,
  });

  factory EvStationListDatum.fromJson(Map<String, dynamic> json) =>
      EvStationListDatum(
        id: json["id"],
        code: json["code"],
        companyId: json["companyId"],
        provinceId: json["provinceId"],
        name: json["name"],
        pricePerKwh: json["pricePerKwh"],
        phoneNumber: json["phoneNumber"],
        description: json["description"],
        address: json["address"],
        imageUrl: json["imageUrl"],
        imageName: json["imageName"],
        lats: json["lats"],
        longs: json["longs"],
        isFavorite: json["isFavorite"],
        totalCharger: json["totalCharger"],
        totalChargerAvailable: json["totalChargerAvailable"],
        value: json["value"],
        gunInform:
            json["gunInform"] == null
                ? []
                : List<EvStationGunInform>.from(
                  json["gunInform"]!.map(
                    (x) => EvStationGunInform.fromJson(x),
                  ),
                ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "companyId": companyId,
    "provinceId": provinceId,
    "name": name,
    "pricePerKwh": pricePerKwh,
    "phoneNumber": phoneNumber,
    "description": description,
    "address": address,
    "imageUrl": imageUrl,
    "imageName": imageName,
    "lats": lats,
    "longs": longs,
    "isFavorite": isFavorite,
    "totalCharger": totalCharger,
    "totalChargerAvailable": totalChargerAvailable,
    "value": value,
    "gunInform":
        gunInform == null
            ? []
            : List<dynamic>.from(gunInform!.map((x) => x.toJson())),
  };
}

class EvStationGunInform {
  String? name;
  int? amount;

  EvStationGunInform({this.name, this.amount});

  factory EvStationGunInform.fromJson(Map<String, dynamic> json) =>
      EvStationGunInform(name: json["name"], amount: json["amount"]);

  Map<String, dynamic> toJson() => {"name": name, "amount": amount};
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({this.serverTimestamp, this.result, this.statusCode});

  factory Header.fromJson(Map<String, dynamic> json) => Header(
    serverTimestamp: json["serverTimestamp"],
    result: json["result"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "serverTimestamp": serverTimestamp,
    "result": result,
    "statusCode": statusCode,
  };
}
