import 'dart:convert';

EvNewsFeedResponse evNewsFeedResponseFromJson(String str) =>
    EvNewsFeedResponse.fromJson(json.decode(str));

String evNewsFeedResponseToJson(EvNewsFeedResponse data) => json.encode(data.toJson());

class EvNewsFeedResponse {
  Header? header;
  EvNewsFeedBody? body;

  EvNewsFeedResponse({this.header, this.body});

  factory EvNewsFeedResponse.fromJson(Map<String, dynamic> json) => EvNewsFeedResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : EvNewsFeedBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {"header": header?.toJson(), "body": body?.toJson()};
}

class EvNewsFeedBody {
  bool? status;
  String? message;
  Pagination? pagination;
  List<EvNewsFeedDatum>? data;

  EvNewsFeedBody({this.status, this.message, this.pagination, this.data});

  factory EvNewsFeedBody.fromJson(Map<String, dynamic> json) => EvNewsFeedBody(
    status: json["status"],
    message: json["message"],
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    data:
        json["data"] == null
            ? []
            : List<EvNewsFeedDatum>.from(json["data"]!.map((x) => EvNewsFeedDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "pagination": pagination?.toJson(),
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class EvNewsFeedDatum {
  int? id;
  String? titleKh;
  String? titleEn;
  String? titleCn;
  String? feedUrl;
  String? profileUrl;
  String? descriptionKh;
  String? descriptionEn;
  String? created;

  EvNewsFeedDatum({
    this.id,
    this.titleKh,
    this.titleEn,
    this.titleCn,
    this.feedUrl,
    this.profileUrl,
    this.descriptionKh,
    this.descriptionEn,
    this.created,
  });

  factory EvNewsFeedDatum.fromJson(Map<String, dynamic> json) => EvNewsFeedDatum(
    id: json["id"],
    titleKh: json["titleKh"],
    titleEn: json["titleEn"],
    titleCn: json["titleCn"],
    feedUrl: json["feedUrl"],
    profileUrl: json["profileUrl"],
    descriptionKh: json["descriptionKh"],
    descriptionEn: json["descriptionEn"],
    created: json["created"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "titleKh": titleKh,
    "titleEn": titleEn,
    "titleCn": titleCn,
    "feedUrl": feedUrl,
    "profileUrl": profileUrl,
    "descriptionKh": descriptionKh,
    "descriptionEn": descriptionEn,
    "created": created,
  };
}

class Pagination {
  int? page;
  int? rowsPerPage;
  int? total;

  Pagination({this.page, this.rowsPerPage, this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      Pagination(page: json["page"], rowsPerPage: json["rowsPerPage"], total: json["total"]);

  Map<String, dynamic> toJson() => {"page": page, "rowsPerPage": rowsPerPage, "total": total};
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
