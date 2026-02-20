import 'dart:convert';

import '../../../../../../models/header.dart';

DestinationEvResponse destinationEvResponseFromJson(String str) =>
    DestinationEvResponse.fromJson(json.decode(str));

String destinationEvResponseToJson(DestinationEvResponse data) =>
    json.encode(data.toJson());

class DestinationEvResponse {
  Header? header;
  List<BodyEv>? body;

  DestinationEvResponse({this.header, this.body});

  factory DestinationEvResponse.fromJson(Map<String, dynamic> json) =>
      DestinationEvResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null
                ? []
                : List<BodyEv>.from(
                  json["body"]!.map((x) => BodyEv.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body":
        body == null ? [] : List<dynamic>.from(body!.map((x) => x.toJson())),
  };
}

class BodyEv {
  int? id;
  String? name;
  String? nameKh;
  String? nameCn;

  BodyEv({this.id, this.name, this.nameKh, this.nameCn});

  factory BodyEv.fromJson(Map<String, dynamic> json) => BodyEv(
    id: json["id"],
    name: json["name"],
    nameKh: json["nameKh"],
    nameCn: json["nameCn"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nameKh": nameKh,
    "nameCn": nameCn,
  };
}
