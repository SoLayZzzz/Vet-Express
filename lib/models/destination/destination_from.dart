

import '../header.dart';

class DesFromResponse {
  Header? header;
  Body? body;

  DesFromResponse({header, body});

  DesFromResponse.fromJson(Map<String, dynamic> json) {
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
  Pagination? pagination;
  List<Data>? data;

  Body({status, message, pagination, data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    pagination = json['pagination'] != null
        ?  Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add( Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
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
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['page'] = page;
    data['rowsPerPage'] = rowsPerPage;
    data['total'] = total;
    return data;
  }
}

class Data {
  String? destinationsFromId;
  String? destinationsFromName;
  String? destinationsFromNameKh;
  String? code;
  int? id;

  Data(
      {destinationsFromId,
        destinationsFromName,
        destinationsFromNameKh,
        code,
        id});

  Data.fromJson(Map<String, dynamic> json) {
    destinationsFromId = json['destinationsFromId'];
    destinationsFromName = json['destinationsFromName'];
    destinationsFromNameKh = json['destinationsFromNameKh'];
    code = json['code'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['destinationsFromId'] = destinationsFromId;
    data['destinationsFromName'] = destinationsFromName;
    data['destinationsFromNameKh'] = destinationsFromNameKh;
    data['code'] = code;
    data['id'] = id;
    return data;
  }
}