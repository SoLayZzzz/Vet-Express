import 'dart:convert';

import '../header.dart';

TotalByJourneyResponse totalByJourneyResponseFromJson(String str) =>
    TotalByJourneyResponse.fromJson(json.decode(str));

String totalByJourneyResponseToJson(TotalByJourneyResponse data) =>
    json.encode(data.toJson());

class TotalByJourneyResponse {
  Header? header;
  List<Body>? body;

  TotalByJourneyResponse({this.header, this.body});

  factory TotalByJourneyResponse.fromJson(Map<String, dynamic> json) =>
      TotalByJourneyResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null
                ? []
                : List<Body>.from(json["body"]!.map((x) => Body.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body":
        body == null ? [] : List<dynamic>.from(body!.map((x) => x.toJson())),
  };
}

class Body {
  int? totalView;
  double? totalRate;
  double? rateOne;
  double? rateTwo;
  double? rateThree;
  double? rateFour;
  double? rateFive;

  Body({
    this.totalView,
    this.totalRate,
    this.rateOne,
    this.rateTwo,
    this.rateThree,
    this.rateFour,
    this.rateFive,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    totalView: json["totalView"],
    totalRate: json["totalRate"],
    rateOne: json["rateOne"],
    rateTwo: json["rateTwo"],
    rateThree: json["rateThree"],
    rateFour: json["rateFour"],
    rateFive: json["rateFive"],
  );

  Map<String, dynamic> toJson() => {
    "totalView": totalView,
    "totalRate": totalRate,
    "rateOne": rateOne,
    "rateTwo": rateTwo,
    "rateThree": rateThree,
    "rateFour": rateFour,
    "rateFive": rateFive,
  };
}
