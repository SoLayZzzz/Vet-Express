
import '../header.dart';

class BookingListFindResponse {
  Header? header;
  Body? body;

  BookingListFindResponse({this.header, this.body});

  BookingListFindResponse.fromJson(Map<String, dynamic> json) {
    header =
    json['header'] != null ? Header.fromJson(json['header']) : null;
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
  String? bookingDate;
  String? travelDate;
  String? code;
  String? destinationFrom;
  String? destinationTo;
  String? vehicleNo;
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
  List<BookingSeatDetailList>? bookingSeatDetailList;

  Data(
      {this.id,
        this.bookingDate,
        this.travelDate,
        this.code,
        this.destinationFrom,
        this.destinationTo,
        this.vehicleNo,
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
        this.bookingSeatDetailList});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingDate = json['bookingDate'];
    travelDate = json['travelDate'];
    code = json['code'];
    destinationFrom = json['destinationFrom'];
    destinationTo = json['destinationTo'];
    vehicleNo = json['vehicleNo'];
    departure = json['departure'];
    arrival = json['arrival'];
    duration = json['duration'];
    paymentType = json['paymentType'];
    transportationType = json['transportationType'];
    boardingPoint = json['boardingPoint'];
    dropOffPoint = json['dropOffPoint'];
    subTotal = json['subTotal'];
    discount = json['discount'];
    totalAmount = json['totalAmount'];
    if (json['bookingSeatDetailList'] != null) {
      bookingSeatDetailList = <BookingSeatDetailList>[];
      json['bookingSeatDetailList'].forEach((v) {
        bookingSeatDetailList!.add(BookingSeatDetailList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookingDate'] = bookingDate;
    data['travelDate'] = travelDate;
    data['code'] = code;
    data['destinationFrom'] = destinationFrom;
    data['destinationTo'] = destinationTo;
    data['vehicleNo'] = vehicleNo;
    data['departure'] = departure;
    data['arrival'] = arrival;
    data['duration'] = duration;
    data['paymentType'] = paymentType;
    data['transportationType'] = transportationType;
    data['boardingPoint'] = boardingPoint;
    data['dropOffPoint'] = dropOffPoint;
    data['subTotal'] = subTotal;
    data['discount'] = discount;
    data['totalAmount'] = totalAmount;
    if (bookingSeatDetailList != null) {
      data['bookingSeatDetailList'] =
          bookingSeatDetailList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingSeatDetailList {
  String? gender;
  String? seatNumber;
  String? price;

  BookingSeatDetailList({this.gender, this.seatNumber, this.price});

  BookingSeatDetailList.fromJson(Map<String, dynamic> json) {
    gender = json['gender'];
    seatNumber = json['seatNumber'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gender'] = gender;
    data['seatNumber'] = seatNumber;
    data['price'] = price;
    return data;
  }
}