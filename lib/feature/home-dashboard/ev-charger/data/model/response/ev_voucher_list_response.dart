class EvVoucherListResponse {
  Header? header;
  Body? body;

  EvVoucherListResponse({this.header, this.body});

  EvVoucherListResponse.fromJson(Map<String, dynamic> json) {
    header =
        json['header'] != null ? new Header.fromJson(json['header']) : null;
    body = json['body'] != null ? new Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.header != null) {
      data['header'] = this.header!.toJson();
    }
    if (this.body != null) {
      data['body'] = this.body!.toJson();
    }
    return data;
  }
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({this.serverTimestamp, this.result, this.statusCode});

  Header.fromJson(Map<String, dynamic> json) {
    serverTimestamp = json['serverTimestamp'];
    result = json['result'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serverTimestamp'] = this.serverTimestamp;
    data['result'] = this.result;
    data['statusCode'] = this.statusCode;
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
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? voucherCode;
  int? voucherBatchId;
  String? batchTitle;
  String? banner;
  String? bannerName;
  int? discountType;
  num? discountValue;
  String? expiresDate;
  int? displayStatus;
  String? statusText;

  Data(
      {this.id,
      this.voucherCode,
      this.voucherBatchId,
      this.batchTitle,
      this.banner,
      this.bannerName,
      this.discountType,
      this.discountValue,
      this.expiresDate,
      this.displayStatus,
      this.statusText});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    voucherCode = json['voucherCode'];
    voucherBatchId = json['voucherBatchId'];
    batchTitle = json['batchTitle'];
    banner = json['banner'];
    bannerName = json['bannerName'];
    discountType = json['discountType'];
    discountValue = json['discountValue'];
    expiresDate = json['expiresDate'];
    displayStatus = json['displayStatus'];
    statusText = json['statusText'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['voucherCode'] = this.voucherCode;
    data['voucherBatchId'] = this.voucherBatchId;
    data['batchTitle'] = this.batchTitle;
    data['banner'] = this.banner;
    data['bannerName'] = this.bannerName;
    data['discountType'] = this.discountType;
    data['discountValue'] = this.discountValue;
    data['expiresDate'] = this.expiresDate;
    data['displayStatus'] = this.displayStatus;
    data['statusText'] = this.statusText;
    return data;
  }
}