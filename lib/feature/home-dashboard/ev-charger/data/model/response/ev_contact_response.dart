import 'dart:convert';

EvContactResponse evContactResponseFromJson(String str) =>
    EvContactResponse.fromJson(json.decode(str));

String evContactResponseToJson(EvContactResponse data) =>
    json.encode(data.toJson());

class EvContactResponse {
  Header? header;
  EvContactBody? body;

  EvContactResponse({this.header, this.body});

  factory EvContactResponse.fromJson(Map<String, dynamic> json) =>
      EvContactResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null ? null : EvContactBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvContactBody {
  bool? status;
  String? message;
  Pagination? pagination;
  List<EvContactDatum>? data;

  EvContactBody({this.status, this.message, this.pagination, this.data});

  factory EvContactBody.fromJson(Map<String, dynamic> json) => EvContactBody(
    status: json["status"],
    message: json["message"],
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
    data:
        json["data"] == null
            ? []
            : List<EvContactDatum>.from(
              json["data"]!.map((x) => EvContactDatum.fromJson(x)),
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

class EvContactDatum {
  int? id;
  String? nameKh;
  String? nameEn;
  String? nameCn;
  int? typeOfContactId;
  String? link;
  String? iconUrl;
  int? ordering;

  EvContactDatum({
    this.id,
    this.nameKh,
    this.nameEn,
    this.nameCn,
    this.typeOfContactId,
    this.link,
    this.iconUrl,
    this.ordering,
  });

  factory EvContactDatum.fromJson(Map<String, dynamic> json) => EvContactDatum(
    id: json["id"],
    nameKh: json["nameKh"],
    nameEn: json["nameEn"],
    nameCn: json["nameCn"],
    typeOfContactId: json["typeOfContactId"],
    link: json["link"],
    iconUrl: json["iconUrl"],
    ordering: json["ordering"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nameKh": nameKh,
    "nameEn": nameEn,
    "nameCn": nameCn,
    "typeOfContactId": typeOfContactId,
    "link": link,
    "iconUrl": iconUrl,
    "ordering": ordering,
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
