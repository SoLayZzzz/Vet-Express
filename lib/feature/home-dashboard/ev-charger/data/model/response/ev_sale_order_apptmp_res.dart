class EvSaleOrderApptmpResponse {
  Header? header;
  Body? body;

  EvSaleOrderApptmpResponse({this.header, this.body});

  EvSaleOrderApptmpResponse.fromJson(Map<String, dynamic> json) {
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
  String? transactionId;
  Data? data;

  Body({this.status, this.message, this.transactionId, this.data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    transactionId = json['transactionId'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['transactionId'] = this.transactionId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? transactionId;
  String? soCode;
  String? stationName;
  String? orderDate;
  int? subTotal;
  int? discountPercentage;
  int? discount;
  int? totalAmount;
  int? totalKwh;

  Data(
      {this.id,
      this.transactionId,
      this.soCode,
      this.stationName,
      this.orderDate,
      this.subTotal,
      this.discountPercentage,
      this.discount,
      this.totalAmount,
      this.totalKwh});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transactionId = json['transactionId'];
    soCode = json['soCode'];
    stationName = json['stationName'];
    orderDate = json['orderDate'];
    subTotal = (json['subTotal'] as num?)?.toInt();
    discountPercentage = (json['discountPercentage'] as num?)?.toInt();
    discount = (json['discount'] as num?)?.toInt();
    totalAmount = (json['totalAmount'] as num?)?.toInt();
    totalKwh = (json['totalKwh'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['transactionId'] = this.transactionId;
    data['soCode'] = this.soCode;
    data['stationName'] = this.stationName;
    data['orderDate'] = this.orderDate;
    data['subTotal'] = this.subTotal;
    data['discountPercentage'] = this.discountPercentage;
    data['discount'] = this.discount;
    data['totalAmount'] = this.totalAmount;
    data['totalKwh'] = this.totalKwh;
    return data;
  }
}