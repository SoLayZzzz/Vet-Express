class MembershipTransactionDetailResponse {
  MembershipTransactionDetailHeader? header;
  MembershipTransactionDetailBody? body;

  MembershipTransactionDetailResponse({this.header, this.body});

  MembershipTransactionDetailResponse.fromJson(Map<String, dynamic> json) {
    header =
        json['header'] == null
            ? null
            : MembershipTransactionDetailHeader.fromJson(json['header']);
    body =
        json['body'] == null
            ? null
            : MembershipTransactionDetailBody.fromJson(json['body']);
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

class MembershipTransactionDetailHeader {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  MembershipTransactionDetailHeader({this.serverTimestamp, this.result, this.statusCode});

  MembershipTransactionDetailHeader.fromJson(Map<String, dynamic> json) {
    serverTimestamp = (json['serverTimestamp'] as num?)?.toInt();
    result = json['result'];
    statusCode = (json['statusCode'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serverTimestamp'] = serverTimestamp;
    data['result'] = result;
    data['statusCode'] = statusCode;
    return data;
  }
}

class MembershipTransactionDetailBody {
  bool? status;
  String? message;
  MembershipTransactionDetailData? data;

  MembershipTransactionDetailBody({this.status, this.message, this.data});

  MembershipTransactionDetailBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] == null
            ? null
            : MembershipTransactionDetailData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class MembershipTransactionDetailData {
  String? transactionId;
  String? stationName;
  String? orderDate;
  int? subTotal;
  int? discountAmount;
  int? discountPercent;
  int? totalAmount;
  int? totalKwh;
  int? pointSpend;

  MembershipTransactionDetailData({
    this.transactionId,
    this.stationName,
    this.orderDate,
    this.subTotal,
    this.discountAmount,
    this.discountPercent,
    this.totalAmount,
    this.totalKwh,
    this.pointSpend,
  });

  MembershipTransactionDetailData.fromJson(Map<String, dynamic> json) {
    transactionId = json['transactionId'];
    stationName = json['stationName'];
    orderDate = json['orderDate'];
    subTotal = (json['subTotal'] as num?)?.toInt();
    discountAmount = (json['discountAmount'] as num?)?.toInt();
    discountPercent = (json['discountPercent'] as num?)?.toInt();
    totalAmount = (json['totalAmount'] as num?)?.toInt();
    totalKwh = (json['totalKwh'] as num?)?.toInt();
    pointSpend = (json['pointSpend'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionId'] = transactionId;
    data['stationName'] = stationName;
    data['orderDate'] = orderDate;
    data['subTotal'] = subTotal;
    data['discountAmount'] = discountAmount;
    data['discountPercent'] = discountPercent;
    data['totalAmount'] = totalAmount;
    data['totalKwh'] = totalKwh;
    data['pointSpend'] = pointSpend;
    return data;
  }
}
