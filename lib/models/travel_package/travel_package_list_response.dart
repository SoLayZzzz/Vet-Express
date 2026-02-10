
import '../header.dart';

class TravelPackageListResponse {
  Header? header;
  List<Body>? body;

  TravelPackageListResponse({this.header, this.body});

  TravelPackageListResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
    if (json['body'] != null) {
      body = <Body>[];
      json['body'].forEach((v) {
        body!.add(Body.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (header != null) {
      data['header'] = header!.toJson();
    }
    if (body != null) {
      data['body'] = body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Body {
  int? id;
  String? name;
  String? nameKh;
  String? nameCn;
  String? photo;
  String? description;
  String? descriptionKh;
  String? descriptionCn;
  double? price;
  String? originalPrice;
  String? termCondition;

  Body({
    this.id,
    this.name,
    this.nameKh,
    this.nameCn,
    this.photo,
    this.description,
    this.descriptionKh,
    this.descriptionCn,
    this.price,
    this.originalPrice,
    this.termCondition
  });

  Body.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameKh = json['nameKh'];
    nameCn = json['nameCn'];
    photo = json['photo'];
    description = json['description'];
    descriptionKh = json['descriptionKh'];
    descriptionCn = json['descriptionCn'];
    price = (json['price'] as num).toDouble();
    originalPrice = json['originalPrice'];
    termCondition = json['termCondition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['nameKh'] = nameKh;
    data['nameCn'] = nameCn;
    data['photo'] = photo;
    data['description'] = description;
    data['descriptionKh'] = descriptionKh;
    data['descriptionCn'] = descriptionCn;
    data['price'] = price;
    data['originalPrice'] = originalPrice;
    data['termCondition'] = termCondition;
    return data;
  }
}

