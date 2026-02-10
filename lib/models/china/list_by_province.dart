
import 'dart:convert';

BranchByProvinceResponse branchByProvinceResponseFromJson(String str) => BranchByProvinceResponse.fromJson(json.decode(str));

String branchByProvinceResponseToJson(BranchByProvinceResponse data) => json.encode(data.toJson());

class BranchByProvinceResponse {
  Header? header;
  BranchByProvinceBody? body;

  BranchByProvinceResponse({
    this.header,
    this.body,
  });

  factory BranchByProvinceResponse.fromJson(Map<String, dynamic> json) => BranchByProvinceResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : BranchByProvinceBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class BranchByProvinceBody {
  bool? status;
  String? message;
  List<BranchByProvinceData>? data;

  BranchByProvinceBody({
    this.status,
    this.message,
    this.data,
  });

  factory BranchByProvinceBody.fromJson(Map<String, dynamic> json) => BranchByProvinceBody(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<BranchByProvinceData>.from(json["data"]!.map((x) => BranchByProvinceData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class BranchByProvinceData {
  int? id;
  String? name;

  BranchByProvinceData({
    this.id,
    this.name,
  });

  factory BranchByProvinceData.fromJson(Map<String, dynamic> json) => BranchByProvinceData(
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
