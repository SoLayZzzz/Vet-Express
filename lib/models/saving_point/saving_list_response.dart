import '../header.dart';

class SavingListResponse {
  Header? header;
  Body? body;

  SavingListResponse({header, body});

  SavingListResponse.fromJson(Map<String, dynamic> json) {
    header =
    json['header'] != null ?  Header.fromJson(json['header']) : null;
    body = json['body'] != null ?  Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
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

  Body({status, message, data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add( Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? date;
  String? transactionNo;
  String? reference;
  String? amount;

  Data({date, transactionNo, reference, amount});

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    transactionNo = json['transactionNo'];
    reference = json['reference'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['date'] = date;
    data['transactionNo'] = transactionNo;
    data['reference'] = reference;
    data['amount'] = amount;
    return data;
  }
}