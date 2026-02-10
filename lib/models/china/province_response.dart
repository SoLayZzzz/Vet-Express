
import 'dart:convert';

ProvinceResponse provinceResponseFromJson(String str) => ProvinceResponse.fromJson(json.decode(str));

String provinceResponseToJson(ProvinceResponse data) => json.encode(data.toJson());

class ProvinceResponse {
  Header? header;
  List<ProvinceBody>? body;

  ProvinceResponse({
    this.header,
    this.body,
  });

  factory ProvinceResponse.fromJson(Map<String, dynamic> json) => ProvinceResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? [] : List<ProvinceBody>.from(json["body"]!.map((x) => ProvinceBody.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body == null ? [] : List<dynamic>.from(body!.map((x) => x.toJson())),
  };
}

class ProvinceBody {
  int? id;
  String? name;

  ProvinceBody({
    this.id,
    this.name,
  });

  factory ProvinceBody.fromJson(Map<String, dynamic> json) => ProvinceBody(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
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
