// To parse this JSON data, do
//
//     final evStationDetailResponse = evStationDetailResponseFromJson(jsonString);

import 'dart:convert';

import 'ev_station_list_response.dart';

EvStationDetailResponse evStationDetailResponseFromJson(String str) =>
    EvStationDetailResponse.fromJson(json.decode(str));

String evStationDetailResponseToJson(EvStationDetailResponse data) =>
    json.encode(data.toJson());

class EvStationDetailResponse {
  Header? header;
  EvStationDetailBody? body;

  EvStationDetailResponse({this.header, this.body});

  factory EvStationDetailResponse.fromJson(Map<String, dynamic> json) =>
      EvStationDetailResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null
                ? null
                : EvStationDetailBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvStationDetailBody {
  bool? status;
  String? message;
  List<EvStationDetailDatum>? data;

  EvStationDetailBody({this.status, this.message, this.data});

  factory EvStationDetailBody.fromJson(Map<String, dynamic> json) =>
      EvStationDetailBody(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<EvStationDetailDatum>.from(
                  json["data"]!.map((x) => EvStationDetailDatum.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class EvStationDetailDatum {
  int? id;
  int? isHasCharger;
  int? franchiseId;
  String? franchiseName;
  String? franchiseProfileUrl;
  String? franchiseProfileName;
  String? name;
  String? address;
  String? lats;
  String? longs;
  String? phoneNumber;
  int? provinceId;
  String? provinceName;
  String? provinceNameKh;
  int? companyId;
  String? companyName;
  double? pricePerKwh;
  double? costingPerKwh;
  double? driverCosting;
  String? description;
  String? telegramId;
  String? imageUrl;
  String? imageName;
  int? isShowOnApp;
  int? bankMerchantId;
  String? bankMerchantName;
  int? is24Hours;
  String? openTime;
  String? closeTime;
  String? openHour;
  List<EvStationChargerGun>? chargerGuns;
  List<EvStationContact>? contactUs;
  List<EvStationAmenity>? amenities;
  List<EvStationAmenity>? surroundings;
  String? createdBy;
  String? created;
  String? modifiedBy;
  String? modified;

  EvStationDetailDatum({
    this.id,
    this.isHasCharger,
    this.franchiseId,
    this.franchiseName,
    this.franchiseProfileUrl,
    this.franchiseProfileName,
    this.name,
    this.address,
    this.lats,
    this.longs,
    this.phoneNumber,
    this.provinceId,
    this.provinceName,
    this.provinceNameKh,
    this.companyId,
    this.companyName,
    this.pricePerKwh,
    this.costingPerKwh,
    this.driverCosting,
    this.description,
    this.telegramId,
    this.imageUrl,
    this.imageName,
    this.isShowOnApp,
    this.bankMerchantId,
    this.bankMerchantName,
    this.is24Hours,
    this.openTime,
    this.closeTime,
    this.openHour,
    this.chargerGuns,
    this.contactUs,
    this.amenities,
    this.surroundings,
    this.createdBy,
    this.created,
    this.modifiedBy,
    this.modified,
  });

  factory EvStationDetailDatum.fromJson(Map<String, dynamic> json) =>
      EvStationDetailDatum(
        id: json["id"],
        isHasCharger: json["isHasCharger"],
        franchiseId: json["franchiseId"],
        franchiseName: json["franchiseName"],
        franchiseProfileUrl: json["franchiseProfileUrl"],
        franchiseProfileName: json["franchiseProfileName"],
        name: json["name"],
        address: json["address"],
        lats: json["lats"],
        longs: json["longs"],
        phoneNumber: json["phoneNumber"],
        provinceId: json["provinceId"],
        provinceName: json["provinceName"],
        provinceNameKh: json["provinceNameKh"],
        companyId: json["companyId"],
        companyName: json["companyName"],
        pricePerKwh: json["pricePerKwh"],
        costingPerKwh: json["costingPerKwh"],
        driverCosting: json["driverCosting"],
        description: json["description"],
        telegramId: json["telegramId"],
        imageUrl: json["imageUrl"],
        imageName: json["imageName"],
        isShowOnApp: json["isShowOnApp"],
        bankMerchantId: json["bankMerchantId"],
        bankMerchantName: json["bankMerchantName"],
        is24Hours: json["is24Hours"],
        openTime: json["openTime"],
        closeTime: json["closeTime"],
        openHour: json["openHour"],
        chargerGuns:
            json["chargerGuns"] == null
                ? []
                : List<EvStationChargerGun>.from(
                  json["chargerGuns"]!.map(
                    (x) => EvStationChargerGun.fromJson(x),
                  ),
                ),
        contactUs:
            json["contactUs"] == null
                ? []
                : List<EvStationContact>.from(
                  json["contactUs"]!.map(
                    (x) => EvStationContact.fromJson(x),
                  ),
                ),
        amenities:
            json["amenities"] == null
                ? []
                : List<EvStationAmenity>.from(
                  json["amenities"]!.map(
                    (x) => EvStationAmenity.fromJson(x),
                  ),
                ),
        surroundings:
            json["surroundings"] == null
                ? []
                : List<EvStationAmenity>.from(
                  json["surroundings"]!.map(
                    (x) => EvStationAmenity.fromJson(x),
                  ),
                ),
        createdBy: json["createdBy"],
        created: json["created"],
        modifiedBy: json["modifiedBy"],
        modified: json["modified"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "isHasCharger": isHasCharger,
    "franchiseId": franchiseId,
    "franchiseName": franchiseName,
    "franchiseProfileUrl": franchiseProfileUrl,
    "franchiseProfileName": franchiseProfileName,
    "name": name,
    "address": address,
    "lats": lats,
    "longs": longs,
    "phoneNumber": phoneNumber,
    "provinceId": provinceId,
    "provinceName": provinceName,
    "provinceNameKh": provinceNameKh,
    "companyId": companyId,
    "companyName": companyName,
    "pricePerKwh": pricePerKwh,
    "costingPerKwh": costingPerKwh,
    "driverCosting": driverCosting,
    "description": description,
    "telegramId": telegramId,
    "imageUrl": imageUrl,
    "imageName": imageName,
    "isShowOnApp": isShowOnApp,
    "bankMerchantId": bankMerchantId,
    "bankMerchantName": bankMerchantName,
    "is24Hours": is24Hours,
    "openTime": openTime,
    "closeTime": closeTime,
    "openHour": openHour,
    "chargerGuns":
        chargerGuns == null
            ? []
            : List<dynamic>.from(chargerGuns!.map((x) => x.toJson())),
    "contactUs":
        contactUs == null
            ? []
            : List<dynamic>.from(contactUs!.map((x) => x.toJson())),
    "amenities":
        amenities == null
            ? []
            : List<dynamic>.from(amenities!.map((x) => x.toJson())),
    "surroundings":
        surroundings == null
            ? []
            : List<dynamic>.from(surroundings!.map((x) => x.toJson())),
    "createdBy": createdBy,
    "created": created,
    "modifiedBy": modifiedBy,
    "modified": modified,
  };
}

class EvStationChargerGun {
  int? chargerGunId;
  String? name;
  double? maxAmperage;
  double? pricePerKwh;
  int? qty;

  EvStationChargerGun({
    this.chargerGunId,
    this.name,
    this.maxAmperage,
    this.pricePerKwh,
    this.qty,
  });

  factory EvStationChargerGun.fromJson(Map<String, dynamic> json) =>
      EvStationChargerGun(
        chargerGunId: json["chargerGunId"],
        name: json["name"],
        maxAmperage: json["maxAmperage"],
        pricePerKwh: json["pricePerKwh"],
        qty: json["qty"],
      );

  Map<String, dynamic> toJson() => {
    "chargerGunId": chargerGunId,
    "name": name,
    "maxAmperage": maxAmperage,
    "pricePerKwh": pricePerKwh,
    "qty": qty,
  };
}

class EvStationContact {
  int? id;
  int? contactTypeId;
  String? contactTypeName;
  String? contactTypeNameKh;
  String? imageUrl;
  String? imageName;
  String? name;
  String? link;

  EvStationContact({
    this.id,
    this.contactTypeId,
    this.contactTypeName,
    this.contactTypeNameKh,
    this.imageUrl,
    this.imageName,
    this.name,
    this.link,
  });

  factory EvStationContact.fromJson(Map<String, dynamic> json) =>
      EvStationContact(
        id: json["id"],
        contactTypeId: json["contactTypeId"],
        contactTypeName: json["contactTypeName"],
        contactTypeNameKh: json["contactTypeNameKh"],
        imageUrl: json["imageUrl"],
        imageName: json["imageName"],
        name: json["name"],
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "contactTypeId": contactTypeId,
    "contactTypeName": contactTypeName,
    "contactTypeNameKh": contactTypeNameKh,
    "imageUrl": imageUrl,
    "imageName": imageName,
    "name": name,
    "link": link,
  };
}

class EvStationAmenity {
  int? id;
  String? name;
  String? nameKh;
  String? imageUrl;
  String? imageName;

  EvStationAmenity({
    this.id,
    this.name,
    this.nameKh,
    this.imageUrl,
    this.imageName,
  });

  factory EvStationAmenity.fromJson(Map<String, dynamic> json) =>
      EvStationAmenity(
        id: json["id"],
        name: json["name"],
        nameKh: json["nameKh"],
        imageUrl: json["imageUrl"],
        imageName: json["imageName"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "nameKh": nameKh,
    "imageUrl": imageUrl,
    "imageName": imageName,
  };
}
