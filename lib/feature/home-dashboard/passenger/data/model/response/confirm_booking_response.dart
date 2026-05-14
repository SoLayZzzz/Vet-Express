import '../../../../../../models/header.dart';
import 'dart:convert';

ConfirmBookingResponse confirmBookingResponseFromJson(String str) =>
    ConfirmBookingResponse.fromJson(json.decode(str));

String confirmBookingResponseToJson(ConfirmBookingResponse data) =>
    json.encode(data.toJson());

class ConfirmBookingResponse {
  Header? header;
  Body? body;

  ConfirmBookingResponse({this.header, this.body});

  factory ConfirmBookingResponse.fromJson(Map<String, dynamic> json) =>
      ConfirmBookingResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class Body {
  String? msg;
  String? transactionId;
  List<OrderPaymentList>? orderPaymentLists;
  List<ConfirmBookingInformation>? confirmBookingInformation;
  List<PaymentMethod>? paymentMethods;
  int? status;
  // Added missing fields below
  String? subTotal;
  String? discount;
  String? discountPercent;
  String? total;

  // class OrderPaymentList {
  // String? desc;
  // String? descKh;
  // String? grandTotal;
  // String? discount;
  // String? disTravel;
  // String? luckyTicket;
  // String? total;


  Body({
    this.msg,
    this.transactionId,
    this.orderPaymentLists,
    this.confirmBookingInformation,
    this.paymentMethods,
    this.status,
    this.subTotal,
    this.discount,
    this.discountPercent,
    this.total,
  });

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    msg: json["msg"],
    transactionId: json["transactionId"],
    orderPaymentLists:
        json["orderPaymentLists"] == null
            ? []
            : List<OrderPaymentList>.from(
              json["orderPaymentLists"]!.map(
                (x) => OrderPaymentList.fromJson(x),
              ),
            ),
    confirmBookingInformation:
        json["confirmBookingInformation"] == null
            ? []
            : List<ConfirmBookingInformation>.from(
              json["confirmBookingInformation"]!.map(
                (x) => ConfirmBookingInformation.fromJson(x),
              ),
            ),
    paymentMethods:
        json["paymentMethods"] == null
            ? []
            : List<PaymentMethod>.from(
              json["paymentMethods"]!.map((x) => PaymentMethod.fromJson(x)),
            ),
    status: json["status"],
    subTotal: json["subTotal"],
    discount: json["discount"],
    discountPercent: json["discountPercent"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "msg": msg,
    "transactionId": transactionId,
    "orderPaymentLists":
        orderPaymentLists == null
            ? []
            : List<dynamic>.from(orderPaymentLists!.map((x) => x.toJson())),
    "confirmBookingInformation":
        confirmBookingInformation == null
            ? []
            : List<dynamic>.from(
              confirmBookingInformation!.map((x) => x.toJson()),
            ),
    "paymentMethods":
        paymentMethods == null
            ? []
            : List<dynamic>.from(paymentMethods!.map((x) => x.toJson())),
    "status": status,
    "subTotal": subTotal,
    "discount": discount,
    "discountPercent": discountPercent,
    "total": total,
  };
}

class ConfirmBookingInformation {
  String? destinationFrom;
  String? departure;
  String? destinationTo;
  List<BookingSeatDetailList>? bookingSeatDetailList;

  ConfirmBookingInformation({
    this.destinationFrom,
    this.departure,
    this.destinationTo,
    this.bookingSeatDetailList,
  });

  factory ConfirmBookingInformation.fromJson(Map<String, dynamic> json) =>
      ConfirmBookingInformation(
        destinationFrom: json["destinationFrom"],
        departure: json["departure"],
        destinationTo: json["destinationTo"],
        bookingSeatDetailList:
            json["bookingSeatDetailList"] == null
                ? []
                : List<BookingSeatDetailList>.from(
                  json["bookingSeatDetailList"]!.map(
                    (x) => BookingSeatDetailList.fromJson(x),
                  ),
                ),
      );

  Map<String, dynamic> toJson() => {
    "destinationFrom": destinationFrom,
    "departure": departure,
    "destinationTo": destinationTo,
    "bookingSeatDetailList":
        bookingSeatDetailList == null
            ? []
            : List<dynamic>.from(bookingSeatDetailList!.map((x) => x.toJson())),
  };
}

class BookingSeatDetailList {
  String? name;
  String? gender;
  String? seatNumber;
  String? price;
  String? discount;
  String? nationality;
  String? nationalityName;
  String? passport;
  String? dob;

  BookingSeatDetailList({
    this.name,
    this.gender,
    this.seatNumber,
    this.price,
    this.discount,
    this.nationality,
    this.nationalityName,
    this.passport,
    this.dob,
  });

  factory BookingSeatDetailList.fromJson(Map<String, dynamic> json) =>
      BookingSeatDetailList(
        name: json["name"],
        gender: json["gender"],
        seatNumber: json["seatNumber"],
        price: json["price"],
        discount: json["discount"],
        nationality: json["nationality"],
        nationalityName: json["nationalityName"],
        passport: json["passport"],
        dob: json["dob"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "gender": gender,
    "seatNumber": seatNumber,
    "price": price,
    "discount": discount,
    "nationality": nationality,
    "nationalityName": nationalityName,
    "passport": passport,
    "dob": dob,
  };
}

class OrderPaymentList {
  String? desc;
  String? descKh;
  String? grandTotal;
  String? discount;
  String? disTravel;
  String? luckyTicket;
  String? total;

  OrderPaymentList({
    this.desc,
    this.descKh,
    this.grandTotal,
    this.discount,
    this.disTravel,
    this.luckyTicket,
    this.total,
  });

  factory OrderPaymentList.fromJson(Map<String, dynamic> json) =>
      OrderPaymentList(
        desc: json["desc"],
        descKh: json["descKh"],
        grandTotal: json["grandTotal"],
        discount: json["discount"],
        disTravel: json["disTravel"],
        luckyTicket: json["luckyTicket"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
    "desc": desc,
    "descKh": descKh,
    "grandTotal": grandTotal,
    "discount": discount,
    "disTravel": disTravel,
    "luckyTicket": luckyTicket,
    "total": total,
  };
}

class PaymentMethod {
  int? id;
  String? name;
  int? discountPercent;
  String? discountAmount;
  int? serviceFeePercent;
  String? serviceFeeAmount;
  int? disUse;

  PaymentMethod({
    this.id,
    this.name,
    this.discountPercent,
    this.discountAmount,
    this.serviceFeePercent,
    this.serviceFeeAmount,
    this.disUse,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: (json["id"] as num?)?.toInt(),
    name: json["name"],
    discountPercent: (json["discountPercent"] as num?)?.toInt(),
    discountAmount: json["discountAmount"],
    serviceFeePercent: (json["serviceFeePercent"] as num?)?.toInt(),
    serviceFeeAmount: json["serviceFeeAmount"],
    disUse: (json["disUse"] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "discountPercent": discountPercent,
    "discountAmount": discountAmount,
    "serviceFeePercent": serviceFeePercent,
    "serviceFeeAmount": serviceFeeAmount,
    "disUse": disUse,
  };
}