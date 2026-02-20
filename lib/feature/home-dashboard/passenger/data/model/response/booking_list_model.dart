import '../../../../../../models/header.dart';

class BookingListModel {
  BookingListModel({this.header, this.body});

  Header? header;
  Body? body;

  factory BookingListModel.fromJson(Map<String, dynamic> json) =>
      BookingListModel(
        header: Header.fromJson(json["header"]),
        body: Body.fromJson(json["body"]),
      );
}

class Body {
  Body({this.status, this.message, this.pagination, this.data});

  bool? status;
  String? message;
  Pagination? pagination;
  List<BookingListDataItem>? data;

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    status: json["status"],
    message: json["message"],
    pagination: Pagination.fromJson(json["pagination"]),
    data: List<BookingListDataItem>.from(
      json["data"].map((x) => BookingListDataItem.fromJson(x)),
    ),
  );
}

class BookingListDataItem {
  BookingListDataItem({
    this.id,
    this.scheduleId,
    this.bookingDate,
    this.travelDate,
    this.code,
    this.destinationFrom,
    this.destinationTo,
    this.departure,
    this.arrival,
    this.duration,
    this.paymentType,
    this.transportationType,
    this.boardingPoint,
    this.dropOffPoint,
    this.subTotal,
    this.discount,
    this.totalAmount,
    this.isSurvey,
    this.isLuckyDraw,
    this.isTravelPackage,
    this.journeyType,
    this.totalSeat,
    this.isRate,
  });

  int? id;
  int? scheduleId;
  String? bookingDate;
  String? travelDate;
  String? code;
  String? destinationFrom;
  String? destinationTo;
  String? departure;
  String? arrival;
  String? duration;
  String? paymentType;
  String? transportationType;
  String? boardingPoint;
  String? dropOffPoint;
  String? subTotal;
  String? discount;
  String? totalAmount;
  int? isSurvey;
  int? isLuckyDraw;
  int? isTravelPackage;
  int? journeyType;
  int? totalSeat;
  int? isRate;

  factory BookingListDataItem.fromJson(Map<String, dynamic> json) =>
      BookingListDataItem(
        id: json["id"],
        scheduleId: json["scheduleId"],
        bookingDate: json["bookingDate"],
        travelDate: json["travelDate"],
        code: json["code"],
        destinationFrom: json["destinationFrom"],
        destinationTo: json["destinationTo"],
        departure: json["departure"],
        arrival: json["arrival"],
        duration: json["duration"],
        paymentType: json["paymentType"],
        transportationType: json["transportationType"],
        boardingPoint: json["boardingPoint"],
        dropOffPoint: json["dropOffPoint"],
        subTotal: json["subTotal"],
        discount: json["discount"],
        totalAmount: json["totalAmount"],
        isSurvey: json["isSurvey"],
        isLuckyDraw: json["isLuckyDraw"],
        isTravelPackage: json["isTravelPackage"],
        journeyType: json["journeyType"],
        totalSeat: json["totalSeat"],
        isRate: json["isRate"],
      );
}

class Pagination {
  Pagination({this.page, this.rowsPerPage, this.total});

  int? page;
  int? rowsPerPage;
  int? total;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    rowsPerPage: json["rowsPerPage"],
    total: json["total"],
  );
}
