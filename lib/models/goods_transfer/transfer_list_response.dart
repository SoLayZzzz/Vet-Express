
import '../header.dart';

class TransferListResponse {
  Header? header;
  Body? body;

  TransferListResponse({this.header, this.body});

  TransferListResponse.fromJson(Map<String, dynamic> json) {
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
  Pagination? pagination;
  List<Data>? data;

  Body({this.status, this.message, this.pagination, this.data});

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

  Pagination({this.page, this.rowsPerPage, this.total});

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
  int? status;
  int? isActive;
  int? id;
  String? code;
  String? date;
  String? senderTelephone;
  String? receiverTelephone;
  int? destinationFromId;
  String? destinationFromEn;
  String? destinationFromKh;
  int? destinationToId;
  String? destinationToEn;
  String? destinationToKh;
  int? typeId;
  int? isSurveyReceiver;
  int? isSurveySender;
  int? qty;

  Data(
      {this.status,
        this.isActive,
        this.id,
        this.code,
        this.date,
        this.senderTelephone,
        this.receiverTelephone,
        this.destinationFromId,
        this.destinationFromEn,
        this.destinationFromKh,
        this.destinationToId,
        this.destinationToEn,
        this.destinationToKh,
        this.typeId,
        this.isSurveyReceiver,
        this.isSurveySender,
        this.qty
      });

  Data.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    isActive = json['isActive'];
    id = json['id'];
    code = json['code'];
    date = json['date'];
    senderTelephone = json['senderTelephone'];
    receiverTelephone = json['receiverTelephone'];
    destinationFromId = json['destinationFromId'];
    destinationFromEn = json['destinationFromEn'];
    destinationFromKh = json['destinationFromKh'];
    destinationToId = json['destinationToId'];
    destinationToEn = json['destinationToEn'];
    destinationToKh = json['destinationToKh'];
    typeId = json['typeId'];
    isSurveyReceiver = json['isSurveyReceiver'];
    isSurveySender = json['isSurveySender'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['isActive'] = isActive;
    data['id'] = id;
    data['code'] = code;
    data['date'] = date;
    data['senderTelephone'] = senderTelephone;
    data['receiverTelephone'] = receiverTelephone;
    data['destinationFromId'] = destinationFromId;
    data['destinationFromEn'] = destinationFromEn;
    data['destinationFromKh'] = destinationFromKh;
    data['destinationToId'] = destinationToId;
    data['destinationToEn'] = destinationToEn;
    data['destinationToKh'] = destinationToKh;
    data['typeId'] = typeId;
    data['isSurveyReceiver'] = isSurveyReceiver;
    data['isSurveySender'] = isSurveySender;
    data['qty'] = qty;
    return data;
  }
}