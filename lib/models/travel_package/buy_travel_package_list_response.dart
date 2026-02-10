
import '../header.dart';

class BuyTravelPackageListResponse {
  Header? header;
  List<Body>? body;

  BuyTravelPackageListResponse({this.header, this.body});

  BuyTravelPackageListResponse.fromJson(Map<String, dynamic> json) {
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
  int? sex;
  int? nationality;
  String? nationalityName;
  String? telephone;
  String? email;
  String? dob;
  String? photoPath;
  String? photo;
  String? address;
  double? packagePrice;
  String? packageCode;
  String? packageDate;
  String? packageExpired;
  String? packageName;
  String? packageNameKh;
  String? packageNameCn;
  String? termCondition;
  String? termConditionKh;
  String? termConditionCn;
  int? type;

  Body(
      {this.id,
        this.name,
        this.sex,
        this.nationality,
        this.nationalityName,
        this.telephone,
        this.email,
        this.dob,
        this.photoPath,
        this.photo,
        this.address,
        this.packagePrice,
        this.packageCode,
        this.packageDate,
        this.packageExpired,
        this.packageName,
        this.packageNameKh,
        this.packageNameCn,
        this.termCondition,
        this.termConditionKh,
        this.termConditionCn,
        this.type,
      });

  Body.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sex = json['sex'];
    nationality = json['nationality'];
    nationalityName = json['nationalityName'];
    telephone = json['telephone'];
    email = json['email'];
    dob = json['dob'];
    photoPath = json['photoPath'];
    photo = json['photo'];
    address = json['address'];
    packagePrice = json['packagePrice'];
    packageCode = json['packageCode'];
    packageDate = json['packageDate'];
    packageExpired = json['packageExpired'];
    packageName = json['packageName'];
    packageNameKh = json['packageNameKh'];
    packageNameCn = json['packageNameCn'];
    termCondition = json['termCondition'];
    termConditionKh = json['termConditionKh'];
    termConditionCn = json['termConditionCn'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['sex'] = sex;
    data['nationality'] = nationality;
    data['nationalityName'] = nationalityName;
    data['telephone'] = telephone;
    data['email'] = email;
    data['dob'] = dob;
    data['photoPath'] = photoPath;
    data['photo'] = photo;
    data['address'] = address;
    data['packagePrice'] = packagePrice;
    data['packageCode'] = packageCode;
    data['packageDate'] = packageDate;
    data['packageExpired'] = packageExpired;
    data['packageName'] = packageName;
    data['packageNameKh'] = packageNameKh;
    data['packageNameCn'] = packageNameCn;
    data['termCondition'] = termCondition;
    data['termConditionKh'] = termConditionKh;
    data['termConditionCn'] = termConditionCn;
    data['type'] = type;
    return data;
  }
}
