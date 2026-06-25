class MembershipBenefitResponse {
  Header? header;
  Body? body;

  MembershipBenefitResponse({this.header, this.body});

  MembershipBenefitResponse.fromJson(Map<String, dynamic> json) {
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
  String? name;
  int? requirePoint;
  int? expireDuration;
  String? description;
  int? discount;
  int? pointMultiplier;
  int? redeemPoint;
  int? isYouAreHere;

  Data(
      {this.id,
      this.name,
      this.requirePoint,
      this.expireDuration,
      this.description,
      this.discount,
      this.pointMultiplier,
      this.redeemPoint,
      this.isYouAreHere});

  Data.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    name = json['name'];
    requirePoint = (json['requirePoint'] as num?)?.toInt();
    expireDuration = (json['expireDuration'] as num?)?.toInt();
    description = json['description'];
    discount = (json['discount'] as num?)?.toInt();
    pointMultiplier = (json['pointMultiplier'] as num?)?.toInt();
    redeemPoint = (json['redeemPoint'] as num?)?.toInt();
    isYouAreHere = (json['isYouAreHere'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['requirePoint'] = this.requirePoint;
    data['expireDuration'] = this.expireDuration;
    data['description'] = this.description;
    data['discount'] = this.discount;
    data['pointMultiplier'] = this.pointMultiplier;
    data['redeemPoint'] = this.redeemPoint;
    data['isYouAreHere'] = this.isYouAreHere;
    return data;
  }
}