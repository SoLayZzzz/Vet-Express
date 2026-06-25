class MembershipInfoResponse {
  Header? header;
  Body? body;

  MembershipInfoResponse({this.header, this.body});

  MembershipInfoResponse.fromJson(Map<String, dynamic> json) {
    header =
        json['header'] != null ? new Header.fromJson(json['header']) : null;
    body = json['body'] != null ? new Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (header != null) {
      data['header'] = header!.toJson();
    }
    if (body != null) {
      data['body'] = body!.toJson();
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
    data['serverTimestamp'] = serverTimestamp;
    data['result'] = result;
    data['statusCode'] = statusCode;
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
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? cardId;
  int? membershipLevelId;
  String? membershipLevelName;
  int? currentPoint;
  int? historyPoint;
  int? requirePoint;
  int? currentLevelRequirePoint;
  int? expireDuration;
  int? expiringPoint;
  int? expiringKwh;
  int? expiringInDays;

  Data(
      {this.id,
      this.cardId,
      this.membershipLevelId,
      this.membershipLevelName,
      this.currentPoint,
      this.historyPoint,
      this.requirePoint,
      this.currentLevelRequirePoint,
      this.expireDuration,
      this.expiringPoint,
      this.expiringKwh,
      this.expiringInDays});

  Data.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    cardId = json['cardId'];
    membershipLevelId = (json['membershipLevelId'] as num?)?.toInt();
    membershipLevelName = json['membershipLevelName'];
    currentPoint = (json['currentPoint'] as num?)?.toInt();
    historyPoint = (json['historyPoint'] as num?)?.toInt();
    requirePoint = (json['requirePoint'] as num?)?.toInt();
    currentLevelRequirePoint = (json['currentLevelRequirePoint'] as num?)?.toInt();
    expireDuration = (json['expireDuration'] as num?)?.toInt();
    expiringPoint = (json['expiringPoint'] as num?)?.toInt();
    expiringKwh = (json['expiringKwh'] as num?)?.toInt();
    expiringInDays = (json['expiringInDays'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['cardId'] = cardId;
    data['membershipLevelId'] = membershipLevelId;
    data['membershipLevelName'] = membershipLevelName;
    data['currentPoint'] = currentPoint;
    data['historyPoint'] = historyPoint;
    data['requirePoint'] = requirePoint;
    data['currentLevelRequirePoint'] = currentLevelRequirePoint;
    data['expireDuration'] = expireDuration;
    data['expiringPoint'] = expiringPoint;
    data['expiringKwh'] = expiringKwh;
    data['expiringInDays'] = expiringInDays;
    return data;
  }
}