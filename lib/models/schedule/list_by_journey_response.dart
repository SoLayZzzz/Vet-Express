import 'dart:convert';

import '../header.dart';

ListByJourneyResponse listByJourneyResponseFromJson(String str) =>
    ListByJourneyResponse.fromJson(json.decode(str));

String listByJourneyResponseToJson(ListByJourneyResponse data) => json.encode(data.toJson());

class ListByJourneyResponse {
  Header? header;
  List<Body>? body;

  ListByJourneyResponse({
    this.header,
    this.body,
  });

  factory ListByJourneyResponse.fromJson(Map<String, dynamic> json) => ListByJourneyResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null ? [] : List<Body>.from(json["body"]!.map((x) => Body.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "header": header?.toJson(),
        "body": body == null ? [] : List<dynamic>.from(body!.map((x) => x.toJson())),
      };
}

class Body {
  String? photo;
  String? name;
  int? score;
  String? comment;

  Body({
    this.photo,
    this.name,
    this.score,
    this.comment,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        photo: json["photo"],
        name: json["name"],
        score: json["score"],
        comment: json["comment"],
      );

  Map<String, dynamic> toJson() => {
        "photo": photo,
        "name": name,
        "score": score,
        "comment": comment,
      };
}
