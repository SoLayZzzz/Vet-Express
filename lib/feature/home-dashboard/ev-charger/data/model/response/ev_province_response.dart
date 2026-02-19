// To parse this JSON data, do
//
//     final evProvinceResponse = evProvinceResponseFromJson(jsonString);

import 'dart:convert';

EvProvinceResponse evProvinceResponseFromJson(String str) =>
    EvProvinceResponse.fromJson(json.decode(str));

String evProvinceResponseToJson(EvProvinceResponse data) =>
    json.encode(data.toJson());

class EvProvinceResponse {
  Header? header;
  EvProvinceBody? body;

  EvProvinceResponse({this.header, this.body});

  factory EvProvinceResponse.fromJson(Map<String, dynamic> json) =>
      EvProvinceResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null ? null : EvProvinceBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvProvinceBody {
  bool? status;
  String? message;
  Pagination? pagination;
  List<EvProvinceDatum>? data;

  EvProvinceBody({this.status, this.message, this.pagination, this.data});

  factory EvProvinceBody.fromJson(Map<String, dynamic> json) => EvProvinceBody(
    status: json["status"],
    message: json["message"],
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
    data:
        json["data"] == null
            ? []
            : List<EvProvinceDatum>.from(
              json["data"]!.map((x) => EvProvinceDatum.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "pagination": pagination?.toJson(),
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class EvProvinceDatum {
  int? id;
  String? nameKh;
  String? nameEn;

  EvProvinceDatum({this.id, this.nameKh, this.nameEn});

  factory EvProvinceDatum.fromJson(Map<String, dynamic> json) =>
      EvProvinceDatum(
        id: json["id"],
        nameKh: json["nameKh"],
        nameEn: json["nameEn"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nameKh": nameKh,
    "nameEn": nameEn,
  };
}

class Pagination {
  int? page;
  int? rowsPerPage;
  int? total;

  Pagination({this.page, this.rowsPerPage, this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    rowsPerPage: json["rowsPerPage"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "rowsPerPage": rowsPerPage,
    "total": total,
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
