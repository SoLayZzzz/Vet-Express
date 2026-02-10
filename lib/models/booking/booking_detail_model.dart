import '../header.dart';
import 'dart:convert';

BookingDetailModel bookingDetailModelFromJson(String str) =>
    BookingDetailModel.fromJson(json.decode(str));

String bookingDetailModelToJson(BookingDetailModel data) => json.encode(data.toJson());

class BookingDetailModel {
  Header? header;
  Body? body;

  BookingDetailModel({
    this.header,
    this.body,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) => BookingDetailModel(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
        "header": header?.toJson(),
        "body": body?.toJson(),
      };
}

class Body {
  bool? status;
  String? message;
  List<BookingDetailDataItem>? data;

  Body({
    this.status,
    this.message,
    this.data,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<BookingDetailDataItem>.from(
                json["data"]!.map((x) => BookingDetailDataItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class BookingDetailDataItem {
  int? id;
  String? bookingDate;
  String? travelDate;
  String? code;
  String? telephone;
  String? destinationFrom;
  String? destinationTo;
  String? departure;
  String? arrival;
  String? duration;
  String? paymentType;
  String? transportationType;
  String? boardingPoint;
  String? boardingPointLat;
  String? boardingPointLong;
  String? boardingPointAddress;
  String? dropOffPoint;
  String? dropOffPointLat;
  String? dropOffPointLong;
  String? dropOffPointAddress;
  String? subTotal;
  String? discount;
  String? totalAmount;
  String? totalVat;
  String? luckDrawFee;
  int? companyType;
  String? transactionId;
  int? journeyType;
  int? totalSeat;
  List<BookingSeatDetailList>? bookingSeatDetailList;

  BookingDetailDataItem({
    this.id,
    this.bookingDate,
    this.travelDate,
    this.code,
    this.telephone,
    this.destinationFrom,
    this.destinationTo,
    this.departure,
    this.arrival,
    this.duration,
    this.paymentType,
    this.transportationType,
    this.boardingPoint,
    this.boardingPointLat,
    this.boardingPointLong,
    this.boardingPointAddress,
    this.dropOffPoint,
    this.dropOffPointLat,
    this.dropOffPointLong,
    this.dropOffPointAddress,
    this.subTotal,
    this.discount,
    this.totalAmount,
    this.totalVat,
    this.luckDrawFee,
    this.companyType,
    this.transactionId,
    this.journeyType,
    this.totalSeat,
    this.bookingSeatDetailList,
  });

  factory BookingDetailDataItem.fromJson(Map<String, dynamic> json) => BookingDetailDataItem(
        id: json["id"],
        bookingDate: json["bookingDate"],
        travelDate: json["travelDate"],
        code: json["code"],
        telephone: json["telephone"],
        destinationFrom: json["destinationFrom"],
        destinationTo: json["destinationTo"],
        departure: json["departure"],
        arrival: json["arrival"],
        duration: json["duration"],
        paymentType: json["paymentType"],
        transportationType: json["transportationType"],
        boardingPoint: json["boardingPoint"],
        boardingPointLat: json["boardingPointLat"],
        boardingPointLong: json["boardingPointLong"],
        boardingPointAddress: json["boardingPointAddress"],
        dropOffPoint: json["dropOffPoint"],
        dropOffPointLat: json["dropOffPointLat"],
        dropOffPointLong: json["dropOffPointLong"],
        dropOffPointAddress: json["dropOffPointAddress"],
        subTotal: json["subTotal"],
        discount: json["discount"],
        totalAmount: json["totalAmount"],
        totalVat: json["totalVat"],
        luckDrawFee: json["luckDrawFee"],
        companyType: json["companyType"],
        transactionId: json["transactionId"],
        journeyType: json["journeyType"],
        totalSeat: json["totalSeat"],
        bookingSeatDetailList: json["bookingSeatDetailList"] == null
            ? []
            : List<BookingSeatDetailList>.from(
                json["bookingSeatDetailList"]!.map((x) => BookingSeatDetailList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bookingDate": bookingDate,
        "travelDate": travelDate,
        "code": code,
        "telephone": telephone,
        "destinationFrom": destinationFrom,
        "destinationTo": destinationTo,
        "departure": departure,
        "arrival": arrival,
        "duration": duration,
        "paymentType": paymentType,
        "transportationType": transportationType,
        "boardingPoint": boardingPoint,
        "boardingPointLat": boardingPointLat,
        "boardingPointLong": boardingPointLong,
        "boardingPointAddress": boardingPointAddress,
        "dropOffPoint": dropOffPoint,
        "dropOffPointLat": dropOffPointLat,
        "dropOffPointLong": dropOffPointLong,
        "dropOffPointAddress": dropOffPointAddress,
        "subTotal": subTotal,
        "discount": discount,
        "totalAmount": totalAmount,
        "totalVat": totalVat,
        "luckDrawFee": luckDrawFee,
        "companyType": companyType,
        "transactionId": transactionId,
        "journeyType": journeyType,
        "totalSeat": totalSeat,
        "bookingSeatDetailList": bookingSeatDetailList == null
            ? []
            : List<dynamic>.from(bookingSeatDetailList!.map((x) => x.toJson())),
      };
}

class BookingSeatDetailList {
  String? name;
  String? gender;
  String? seatNumber;
  String? price;
  String? nationalityName;
  String? passport;
  String? dob;

  BookingSeatDetailList({
    this.name,
    this.gender,
    this.seatNumber,
    this.price,
    this.nationalityName,
    this.passport,
    this.dob,
  });

  factory BookingSeatDetailList.fromJson(Map<String, dynamic> json) => BookingSeatDetailList(
        name: json["name"],
        gender: json["gender"],
        seatNumber: json["seatNumber"],
        price: json["price"],
        nationalityName: json["nationalityName"],
        passport: json["passport"],
        dob: json["dob"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "gender": gender,
        "seatNumber": seatNumber,
        "price": price,
        "nationalityName": nationalityName,
        "passport": passport,
        "dob": dob,
      };
}
