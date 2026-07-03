class EvCalculateResponse {
  Header? header;
  Body? body;

  EvCalculateResponse({this.header, this.body});

  EvCalculateResponse.fromJson(Map<String, dynamic> json) {
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
  bool? result;
  int? statusCode;

  Header({this.result, this.statusCode});

  Header.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Body {
  bool? status;
  String? message;
  Data? data;

  Body({this.status, this.message, this.data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  double? discountPercentage;
  double? discountAmountUsd;
  double? discountAmountKhr;

  Data(
      {this.discountPercentage,
      this.discountAmountUsd,
      this.discountAmountKhr});

  Data.fromJson(Map<String, dynamic> json) {
    discountPercentage = (json['discountPercentage'] as num?)?.toDouble();
    discountAmountUsd = (json['discountAmountUsd'] as num?)?.toDouble();
    discountAmountKhr = (json['discountAmountKhr'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['discountPercentage'] = this.discountPercentage;
    data['discountAmountUsd'] = this.discountAmountUsd;
    data['discountAmountKhr'] = this.discountAmountKhr;
    return data;
  }
}
