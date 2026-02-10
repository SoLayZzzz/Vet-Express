
import '../header.dart';

class FindTravelPackageResponse {
  Header? header;
  Body? body;

  FindTravelPackageResponse({this.header, this.body});

  FindTravelPackageResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (header != null) {
      data['header'] = header!.toJson();
    }
    if (body != null) {
      data['body'] = body!.toJson();
    }
    return data;
  }
}

class Body {
  bool? status;
  String? message;
  List<Data>? data;

  Body({this.status, this.message, this.data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? nameKh;
  String? nameCn;
  String? photo;
  String? description;
  String? descriptionKh;
  String? descriptionCn;
  double? price;
  String? termCondition;
  String? termConditionKh;
  String? termConditionCn;
  List<dynamic>? otherPhoto;

  Data({
    this.id,
    this.name,
    this.nameKh,
    this.nameCn,
    this.photo,
    this.description,
    this.descriptionKh,
    this.descriptionCn,
    this.price,
    this.termCondition,
    this.termConditionKh,
    this.termConditionCn,
    this.otherPhoto,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameKh = json['nameKh'];
    nameCn = json['nameCn'];
    photo = json['photo'];
    description = json['description'];
    descriptionKh = json['descriptionKh'];
    descriptionCn = json['descriptionCn'];
    price = json['price'];
    termCondition = json['termCondition'];
    termConditionKh = json['termConditionKh'];
    termConditionCn = json['termConditionCn'];
    if (json['otherPhoto'] != null) {
      otherPhoto = <dynamic>[];
      json['otherPhoto'].forEach((v) {
        otherPhoto!.add(Data.fromJson(v));
      });
    }
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
    data['termCondition'] = termCondition;
    data['termConditionKh'] = termConditionKh;
    data['termConditionCn'] = termConditionCn;
    if (otherPhoto != null) {
      data['otherPhoto'] = otherPhoto!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}