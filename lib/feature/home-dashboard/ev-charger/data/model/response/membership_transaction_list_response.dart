class MembershipTransactionListResponse {
  MembershipTransactionListHeader? header;
  MembershipTransactionListBody? body;

  MembershipTransactionListResponse({this.header, this.body});

  MembershipTransactionListResponse.fromJson(Map<String, dynamic> json) {
    header =
        json['header'] == null
            ? null
            : MembershipTransactionListHeader.fromJson(json['header']);
    body =
        json['body'] == null
            ? null
            : MembershipTransactionListBody.fromJson(json['body']);
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

class MembershipTransactionListHeader {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  MembershipTransactionListHeader({this.serverTimestamp, this.result, this.statusCode});

  MembershipTransactionListHeader.fromJson(Map<String, dynamic> json) {
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

class MembershipTransactionListBody {
  bool? status;
  String? message;
  MembershipTransactionListPagination? pagination;
  List<MembershipTransactionGroup>? data;

  MembershipTransactionListBody({this.status, this.message, this.pagination, this.data});

  MembershipTransactionListBody.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    pagination =
        json['pagination'] == null
            ? null
            : MembershipTransactionListPagination.fromJson(json['pagination']);
    if (json['data'] != null) {
      data = <MembershipTransactionGroup>[];
      for (final v in json['data']) {
        data!.add(MembershipTransactionGroup.fromJson(v));
      }
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

class MembershipTransactionListPagination {
  int? page;
  int? rowsPerPage;
  int? total;

  MembershipTransactionListPagination({this.page, this.rowsPerPage, this.total});

  MembershipTransactionListPagination.fromJson(Map<String, dynamic> json) {
    page = (json['page'] as num?)?.toInt();
    rowsPerPage = (json['rowsPerPage'] as num?)?.toInt();
    total = (json['total'] as num?)?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['rowsPerPage'] = rowsPerPage;
    data['total'] = total;
    return data;
  }
}

class MembershipTransactionGroup {
  String? date;
  List<MembershipTransactionItem>? transactions;

  MembershipTransactionGroup({this.date, this.transactions});

  MembershipTransactionGroup.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    if (json['transactions'] != null) {
      transactions = <MembershipTransactionItem>[];
      for (final v in json['transactions']) {
        transactions!.add(MembershipTransactionItem.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MembershipTransactionItem {
  int? id;
  int? type;
  String? typeName;
  int? points;
  int? kwh;
  int? currentPoint;
  int? finalPoint;
  String? description;
  int? salesOrderId;
  String? created;

  MembershipTransactionItem({
    this.id,
    this.type,
    this.typeName,
    this.points,
    this.kwh,
    this.currentPoint,
    this.finalPoint,
    this.description,
    this.salesOrderId,
    this.created,
  });

  MembershipTransactionItem.fromJson(Map<String, dynamic> json) {
    id = (json['id'] as num?)?.toInt();
    type = (json['type'] as num?)?.toInt();
    typeName = json['typeName'];
    points = (json['points'] as num?)?.toInt();
    kwh = (json['kwh'] as num?)?.toInt();
    currentPoint = (json['currentPoint'] as num?)?.toInt();
    finalPoint = (json['finalPoint'] as num?)?.toInt();
    description = json['description'];
    salesOrderId = (json['salesOrderId'] as num?)?.toInt();
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['typeName'] = typeName;
    data['points'] = points;
    data['kwh'] = kwh;
    data['currentPoint'] = currentPoint;
    data['finalPoint'] = finalPoint;
    data['description'] = description;
    data['salesOrderId'] = salesOrderId;
    data['created'] = created;
    return data;
  }
}
