

import '../header.dart';

class BookingListResponse {
  Header? header;
  Body? body;

  BookingListResponse({header, body});

  BookingListResponse.fromJson(Map<String, dynamic> json) {
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
  Pagination? pagination;
  List<Data>? data;

  Body({status, message, pagination, data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
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
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? page;
  int? rowsPerPage;
  int? total;

  Pagination({page, rowsPerPage, total});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    rowsPerPage = json['rowsPerPage'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['rowsPerPage'] = rowsPerPage;
    data['total'] = total;
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
  String? departure;
  String? vehicleNo;
  String? arrival;
  String? duration;
  String? paymentType;
  String? transportationType;
  String? boardingPoint;
  String? dropOffPoint;
  String? subTotal;
  String? discount;
  String? totalAmount;

  Data(
      {id,
        bookingDate,
        travelDate,
        code,
        destinationFrom,
        destinationTo,
        departure,
        vehicleNo,
        arrival,
        duration,
        paymentType,
        transportationType,
        boardingPoint,
        dropOffPoint,
        subTotal,
        discount,
        totalAmount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingDate = json['bookingDate'];
    travelDate = json['travelDate'];
    code = json['code'];
    destinationFrom = json['destinationFrom'];
    destinationTo = json['destinationTo'];
    departure = json['departure'];
    vehicleNo = json['vehicleNo'];
    arrival = json['arrival'];
    duration = json['duration'];
    paymentType = json['paymentType'];
    transportationType = json['transportationType'];
    boardingPoint = json['boardingPoint'];
    dropOffPoint = json['dropOffPoint'];
    subTotal = json['subTotal'];
    discount = json['discount'];
    totalAmount = json['totalAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookingDate'] = bookingDate;
    data['travelDate'] = travelDate;
    data['code'] = code;
    data['destinationFrom'] = destinationFrom;
    data['destinationTo'] = destinationTo;
    data['departure'] = departure;
    data['vehicleNo'] = vehicleNo;
    data['arrival'] = arrival;
    data['duration'] = duration;
    data['paymentType'] = paymentType;
    data['transportationType'] = transportationType;
    data['boardingPoint'] = boardingPoint;
    data['dropOffPoint'] = dropOffPoint;
    data['subTotal'] = subTotal;
    data['discount'] = discount;
    data['totalAmount'] = totalAmount;
    return data;
  }
}