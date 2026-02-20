import '../../../../models/header.dart';
import '../../../../models/pagination.dart';

class DesToResponse {
  Header? header;
  Body? body;

  DesToResponse({header, body});

  DesToResponse.fromJson(Map<String, dynamic> json) {
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

class Data {
  String? destinationsToId;
  String? destinationsToName;
  String? destinationsToNameKh;
  String? code;
  int? id;

  Data({destinationsToId, destinationsToName, destinationsToNameKh, code, id});

  Data.fromJson(Map<String, dynamic> json) {
    destinationsToId = json['destinationsToId'];
    destinationsToName = json['destinationsToName'];
    destinationsToNameKh = json['destinationsToNameKh'];
    code = json['code'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['destinationsToId'] = destinationsToId;
    data['destinationsToName'] = destinationsToName;
    data['destinationsToNameKh'] = destinationsToNameKh;
    data['code'] = code;
    data['id'] = id;
    return data;
  }
}
