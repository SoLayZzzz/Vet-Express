import 'dart:convert';

EvFaqResponse evFaqResponseFromJson(String str) =>
    EvFaqResponse.fromJson(json.decode(str));

String evFaqResponseToJson(EvFaqResponse data) => json.encode(data.toJson());

class EvFaqResponse {
  Header? header;
  EvFaqBody? body;

  EvFaqResponse({this.header, this.body});

  factory EvFaqResponse.fromJson(Map<String, dynamic> json) => EvFaqResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : EvFaqBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvFaqBody {
  bool? status;
  String? message;
  Pagination? pagination;
  List<EvFaqDatum>? data;

  EvFaqBody({this.status, this.message, this.pagination, this.data});

  factory EvFaqBody.fromJson(Map<String, dynamic> json) => EvFaqBody(
    status: json["status"],
    message: json["message"],
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
    data:
        json["data"] == null
            ? []
            : List<EvFaqDatum>.from(
              json["data"]!.map((x) => EvFaqDatum.fromJson(x)),
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

class EvFaqDatum {
  int? id;
  String? questionEn;
  String? questionKh;
  String? questionCh;
  String? answerEn;
  String? answerKh;
  String? answerCh;

  EvFaqDatum({
    this.id,
    this.questionEn,
    this.questionKh,
    this.questionCh,
    this.answerEn,
    this.answerKh,
    this.answerCh,
  });

  factory EvFaqDatum.fromJson(Map<String, dynamic> json) => EvFaqDatum(
    id: json["id"],
    questionEn: json["questionEn"],
    questionKh: json["questionKh"],
    questionCh: json["questionCh"],
    answerEn: json["answerEn"],
    answerKh: json["answerKh"],
    answerCh: json["answerCh"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "questionEn": questionEn,
    "questionKh": questionKh,
    "questionCh": questionCh,
    "answerEn": answerEn,
    "answerKh": answerKh,
    "answerCh": answerCh,
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
