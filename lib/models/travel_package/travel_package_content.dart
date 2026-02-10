
import '../header.dart';

class TravelPackageContent {
  Header? header;
  List<Body>? body;

  TravelPackageContent({
    this.header,
    this.body,
  });

  factory TravelPackageContent.fromJson(Map<String, dynamic> json) => TravelPackageContent(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? [] : List<Body>.from(json["body"]!.map((x) => Body.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body == null ? [] : List<dynamic>.from(body!.map((x) => x.toJson())),
  };
}

class Body {
  String? titleKh;
  String? titleEn;
  String? titleCn;
  String? descKh;
  String? descEn;
  String? descCn;

  Body({
    this.titleKh,
    this.titleEn,
    this.titleCn,
    this.descKh,
    this.descEn,
    this.descCn,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    titleKh: json["titleKh"],
    titleEn: json["titleEn"],
    titleCn: json["titleCn"],
    descKh: json["descKh"],
    descEn: json["descEn"],
    descCn: json["descCn"],
  );

  Map<String, dynamic> toJson() => {
    "titleKh": titleKh,
    "titleEn": titleEn,
    "titleCn": titleCn,
    "descKh": descKh,
    "descEn": descEn,
    "descCn": descCn,
  };
}

