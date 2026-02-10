
import 'dart:convert';

WarehouseResponse chinaWarehouseResponseFromJson(String str) => WarehouseResponse.fromJson(json.decode(str));

String chinaWarehouseResponseToJson(WarehouseResponse data) => json.encode(data.toJson());

class WarehouseResponse {
  Header? header;
  WarehouseBody? body;

  WarehouseResponse({
    this.header,
    this.body,
  });

  factory WarehouseResponse.fromJson(Map<String, dynamic> json) => WarehouseResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : WarehouseBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class WarehouseBody {
  bool? status;
  String? message;
  List<WarehouseData>? data;

  WarehouseBody({
    this.status,
    this.message,
    this.data,
  });

  factory WarehouseBody.fromJson(Map<String, dynamic> json) => WarehouseBody(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<WarehouseData>.from(json["data"]!.map((x) => WarehouseData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class WarehouseData {
  String? name;
  String? telephone;
  String? address;
  int? type;

  WarehouseData({
    this.name,
    this.telephone,
    this.address,
    this.type,
  });

  factory WarehouseData.fromJson(Map<String, dynamic> json) => WarehouseData(
    name: json["name"],
    telephone: json["telephone"],
    address: json["address"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "telephone": telephone,
    "address": address,
    "type": type,
  };
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({
    this.serverTimestamp,
    this.result,
    this.statusCode,
  });

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
