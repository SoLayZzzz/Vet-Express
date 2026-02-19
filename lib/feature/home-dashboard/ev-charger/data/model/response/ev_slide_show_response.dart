import 'dart:convert';

EvSlideShowResponse evSlideShowResponseFromJson(String str) =>
    EvSlideShowResponse.fromJson(json.decode(str));

String evSlideShowResponseToJson(EvSlideShowResponse data) =>
    json.encode(data.toJson());

class EvSlideShowResponse {
  Header? header;
  EvSlideShowBody? body;

  EvSlideShowResponse({this.header, this.body});

  factory EvSlideShowResponse.fromJson(
    Map<String, dynamic> json,
  ) => EvSlideShowResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : EvSlideShowBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvSlideShowBody {
  bool? status;
  String? message;
  Pagination? pagination;
  List<EvSlideShowDatum>? data;

  EvSlideShowBody({this.status, this.message, this.pagination, this.data});

  factory EvSlideShowBody.fromJson(Map<String, dynamic> json) =>
      EvSlideShowBody(
        status: json["status"],
        message: json["message"],
        pagination:
            json["pagination"] == null
                ? null
                : Pagination.fromJson(json["pagination"]),
        data:
            json["data"] == null
                ? []
                : List<EvSlideShowDatum>.from(
                  json["data"]!.map((x) => EvSlideShowDatum.fromJson(x)),
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

class EvSlideShowDatum {
  int? id;
  int? ordering;
  String? attachLink;
  String? imageName;
  String? imageUrl;

  EvSlideShowDatum({
    this.id,
    this.ordering,
    this.attachLink,
    this.imageName,
    this.imageUrl,
  });

  factory EvSlideShowDatum.fromJson(Map<String, dynamic> json) =>
      EvSlideShowDatum(
        id: json["id"],
        ordering: json["ordering"],
        attachLink: json["attachLink"],
        imageName: json["imageName"],
        imageUrl: json["imageUrl"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ordering": ordering,
    "attachLink": attachLink,
    "imageName": imageName,
    "imageUrl": imageUrl,
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
