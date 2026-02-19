import 'dart:convert';

EvPolicyResponse evPolicyResponseFromJson(String str) =>
    EvPolicyResponse.fromJson(json.decode(str));

String evPolicyResponseToJson(EvPolicyResponse data) =>
    json.encode(data.toJson());

class EvPolicyResponse {
  Header? header;
  EvPolicyBody? body;

  EvPolicyResponse({this.header, this.body});

  factory EvPolicyResponse.fromJson(Map<String, dynamic> json) =>
      EvPolicyResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : EvPolicyBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvPolicyBody {
  bool? status;
  String? message;
  Pagination? pagination;
  List<EvPolicyDatum>? data;

  EvPolicyBody({this.status, this.message, this.pagination, this.data});

  factory EvPolicyBody.fromJson(Map<String, dynamic> json) => EvPolicyBody(
    status: json["status"],
    message: json["message"],
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
    data:
        json["data"] == null
            ? []
            : List<EvPolicyDatum>.from(
              json["data"]!.map((x) => EvPolicyDatum.fromJson(x)),
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

class EvPolicyDatum {
  int? id;
  String? descriptionKh;
  String? descriptionEn;
  String? descriptionCh;

  EvPolicyDatum({
    this.id,
    this.descriptionKh,
    this.descriptionEn,
    this.descriptionCh,
  });

  factory EvPolicyDatum.fromJson(Map<String, dynamic> json) => EvPolicyDatum(
    id: json["id"],
    descriptionKh: json["descriptionKh"],
    descriptionEn: json["descriptionEn"],
    descriptionCh: json["descriptionCh"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "descriptionKh": descriptionKh,
    "descriptionEn": descriptionEn,
    "descriptionCh": descriptionCh,
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
