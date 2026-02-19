import '../../../../../models/header.dart';

class CheckPackageApplyResponse {
  Header? header;
  Body? body;

  CheckPackageApplyResponse({this.header, this.body});

  factory CheckPackageApplyResponse.fromJson(Map<String, dynamic> json) =>
      CheckPackageApplyResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class Body {
  String? msg;
  int? status;
  int? discount;

  Body({this.msg, this.status, this.discount});

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    msg: json["msg"],
    status: json["status"],
    discount: json["discount"],
  );

  Map<String, dynamic> toJson() => {
    "msg": msg,
    "status": status,
    "discount": discount,
  };
}
