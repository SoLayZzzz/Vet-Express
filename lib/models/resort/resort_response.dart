

import '../header.dart';

class ResortResponse {
  Header? header;
  List<ResortBody>? body;

  ResortResponse({
    this.header,
    this.body,
  });

  factory ResortResponse.fromJson(Map<String, dynamic> json) => ResortResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? [] : List<ResortBody>.from(json["body"]!.map((x) => ResortBody.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body == null ? [] : List<dynamic>.from(body!.map((x) => x.toJson())),
  };
}

class ResortBody {
  String? name;
  String? price;
  String? link;
  String? photo;

  ResortBody({
    this.name,
    this.price,
    this.link,
    this.photo,
  });

  factory ResortBody.fromJson(Map<String, dynamic> json) => ResortBody(
    name: json["name"],
    price: json["price"],
    link: json["link"],
    photo: json["photo"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "link": link,
    "photo": photo,
  };
}
