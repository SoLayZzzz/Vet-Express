import '../../../../../models/header.dart';

class NationalityResponse {
  Header? header;
  Body? body;

  NationalityResponse({this.header, this.body});

  factory NationalityResponse.fromJson(Map<String, dynamic> json) =>
      NationalityResponse(
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
  List<NationalityResponseData>? data;

  Body({this.status, this.message, this.data});

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    status: json["status"],
    message: json["message"],
    data:
        json["data"] == null
            ? []
            : List<NationalityResponseData>.from(
              json["data"]!.map((x) => NationalityResponseData.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class NationalityResponseData {
  int? id;
  String? name;

  NationalityResponseData({this.id, this.name});

  factory NationalityResponseData.fromJson(Map<String, dynamic> json) =>
      NationalityResponseData(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
