import '../header.dart';

class RequestGoodsTransferResponse {
  Header? header;
  Body? body;

  RequestGoodsTransferResponse({header, body});

  RequestGoodsTransferResponse.fromJson(Map<String, dynamic> json) {
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
  String? code;
  String? date;
  String? senderTelephone;
  String? receiverTelephone;
  String? destinationTo;
  double? itemValue;
  int? itemQty;
  String? uomName;
  String? created;

  Data(
      {code,
        date,
        senderTelephone,
        receiverTelephone,
        destinationTo,
        itemValue,
        itemQty,
        uomName,
        created});

  Data.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    date = json['date'];
    senderTelephone = json['senderTelephone'];
    receiverTelephone = json['receiverTelephone'];
    destinationTo = json['destinationTo'];
    itemValue = json['itemValue'];
    itemQty = json['itemQty'];
    uomName = json['uomName'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['code'] = code;
    data['date'] = date;
    data['senderTelephone'] = senderTelephone;
    data['receiverTelephone'] = receiverTelephone;
    data['destinationTo'] = destinationTo;
    data['itemValue'] = itemValue;
    data['itemQty'] = itemQty;
    data['uomName'] = uomName;
    data['created'] = created;
    return data;
  }
}