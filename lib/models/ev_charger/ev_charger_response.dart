// To parse this JSON data, do
//
//     final evChargerResponse = evChargerResponseFromJson(jsonString);

import 'dart:convert';

EvChargerResponse evChargerResponseFromJson(String str) =>
    EvChargerResponse.fromJson(json.decode(str));

String evChargerResponseToJson(EvChargerResponse data) => json.encode(data.toJson());

class EvChargerResponse {
  Header? header;
  List<BodyEV>? body;

  EvChargerResponse({this.header, this.body});

  factory EvChargerResponse.fromJson(Map<String, dynamic> json) => EvChargerResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body:
        json["body"] == null ? [] : List<BodyEV>.from(json["body"]!.map((x) => BodyEV.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body == null ? [] : List<dynamic>.from(body!.map((x) => x.toJson())),
  };
}

class BodyEV {
  String? name;
  String? nameKh;
  String? nameCn;
  String? image;
  String? telephone;
  String? evChargerQty;
  String? evChargerQtyKh;
  String? evChargerQtyCn;
  String? chargePoint;
  String? chargePointKh;
  String? chargePointCn;
  String? vehicleQty;
  String? vehicleQtyKh;
  String? vehicleQtyCn;
  String? address;
  String? addressKh;
  String? addressCn;
  String? lats;
  String? longs;
  int? isOpen;

  BodyEV({
    this.name,
    this.nameKh,
    this.nameCn,
    this.image,
    this.telephone,
    this.evChargerQty,
    this.evChargerQtyKh,
    this.evChargerQtyCn,
    this.chargePoint,
    this.chargePointKh,
    this.chargePointCn,
    this.vehicleQty,
    this.vehicleQtyKh,
    this.vehicleQtyCn,
    this.address,
    this.addressKh,
    this.addressCn,
    this.lats,
    this.longs,
    this.isOpen,
  });

  factory BodyEV.fromJson(Map<String, dynamic> json) => BodyEV(
    name: json["name"],
    nameKh: json["nameKh"],
    nameCn: json["nameCn"],
    image: json["image"],
    telephone: json["telephone"],
    evChargerQty: json["evChargerQty"],
    evChargerQtyKh: json["evChargerQtyKh"],
    evChargerQtyCn: json["evChargerQtyCn"],
    chargePoint: json["chargePoint"],
    chargePointKh: json["chargePointKh"],
    chargePointCn: json["chargePointCn"],
    vehicleQty: json["vehicleQty"],
    vehicleQtyKh: json["vehicleQtyKh"],
    vehicleQtyCn: json["vehicleQtyCn"],
    address: json["address"],
    addressKh: json["addressKh"],
    addressCn: json["addressCn"],
    lats: json["lats"],
    longs: json["longs"],
    isOpen: json["isOpen"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "nameKh": nameKh,
    "nameCn": nameCn,
    "image": image,
    "telephone": telephone,
    "evChargerQty": evChargerQty,
    "evChargerQtyKh": evChargerQtyKh,
    "evChargerQtyCn": evChargerQtyCn,
    "chargePoint": chargePoint,
    "chargePointKh": chargePointKh,
    "chargePointCn": chargePointCn,
    "vehicleQty": vehicleQty,
    "vehicleQtyKh": vehicleQtyKh,
    "vehicleQtyCn": vehicleQtyCn,
    "address": address,
    "addressKh": addressKh,
    "addressCn": addressCn,
    "lats": lats,
    "longs": longs,
    "isOpen": isOpen,
  };
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
