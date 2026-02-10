
import 'dart:convert';

CustomerChinaListResponse customerChinaListResponseFromJson(String str) =>
    CustomerChinaListResponse.fromJson(json.decode(str));

String customerChinaListResponseToJson(CustomerChinaListResponse data) =>
    json.encode(data.toJson());

class CustomerChinaListResponse {
  Header? header;
  CustomerChinaListBody? body;

  CustomerChinaListResponse({this.header, this.body});

  factory CustomerChinaListResponse.fromJson(Map<String, dynamic> json) =>
      CustomerChinaListResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : CustomerChinaListBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {"header": header?.toJson(), "body": body?.toJson()};
}

class CustomerChinaListBody {
  bool? status;
  String? message;
  List<CustomerChinaListData>? data;

  CustomerChinaListBody({this.status, this.message, this.data});

  factory CustomerChinaListBody.fromJson(Map<String, dynamic> json) => CustomerChinaListBody(
    status: json["status"],
    message: json["message"],
    data:
        json["data"] == null
            ? []
            : List<CustomerChinaListData>.from(
              json["data"]!.map((x) => CustomerChinaListData.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CustomerChinaListData {
  String? code;
  String? name;
  String? telephone;
  String? branchName;
  String? address;

  CustomerChinaListData({this.code, this.name, this.telephone, this.branchName, this.address});

  factory CustomerChinaListData.fromJson(Map<String, dynamic> json) => CustomerChinaListData(
    code: json["code"],
    name: json["name"],
    telephone: json["telephone"],
    branchName: json["branchName"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "telephone": telephone,
    "branchName": branchName,
    "address": address,
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
