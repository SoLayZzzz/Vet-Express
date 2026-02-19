import '../../../../../../models/header.dart';

class NotificationResponse {
  Header? header;
  Body? body;

  NotificationResponse({header, body});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
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
  Pagination? pagination;
  List<Data>? data;

  Body({status, message, pagination, data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
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
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? page;
  int? rowsPerPage;
  int? total;

  Pagination({page, rowsPerPage, total});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    rowsPerPage = json['rowsPerPage'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['rowsPerPage'] = rowsPerPage;
    data['total'] = total;
    return data;
  }
}

class Data {
  int? id;
  int? goodsTransferId;
  String? title;
  String? message;
  String? type;
  int? isRead;
  String? created;

  Data({id, goodsTransferId, title, message, type, isRead, created});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    goodsTransferId = json['goodsTransferId'];
    title = json['title'];
    message = json['message'];
    type = json['type'];
    isRead = json['isRead'];
    created = json['created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['goodsTransferId'] = goodsTransferId;
    data['title'] = title;
    data['message'] = message;
    data['type'] = type;
    data['isRead'] = isRead;
    data['created'] = created;
    return data;
  }
}
