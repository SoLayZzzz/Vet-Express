import '../../../../../../models/header.dart';

class GoodsFindResponse {
  Header? header;
  Body? body;

  GoodsFindResponse({header, body});

  GoodsFindResponse.fromJson(Map<String, dynamic> json) {
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
  List<Data>? data;

  Body({status, message, data});

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
  int? qty;
  List<GoodsTransferMoveList>? goodsTransferMoveList;

  Data({
    status,
    isActive,
    id,
    code,
    date,
    senderTelephone,
    receiverTelephone,
    destinationFromId,
    destinationFromEn,
    destinationFromKh,
    destinationToId,
    destinationToEn,
    destinationToKh,
    typeId,
    qty,
    goodsTransferMoveList,
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
    qty = json['qty'];
    if (json['goodsTransferMoveList'] != null) {
      goodsTransferMoveList = <GoodsTransferMoveList>[];
      json['goodsTransferMoveList'].forEach((v) {
        goodsTransferMoveList!.add(GoodsTransferMoveList.fromJson(v));
      });
    }
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
    data['qty'] = qty;
    if (goodsTransferMoveList != null) {
      data['goodsTransferMoveList'] =
          goodsTransferMoveList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GoodsTransferMoveList {
  int? status;
  String? created;
  String? msg;

  GoodsTransferMoveList({status, created, msg});

  GoodsTransferMoveList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    created = json['created'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['created'] = created;
    data['msg'] = msg;
    return data;
  }
}
