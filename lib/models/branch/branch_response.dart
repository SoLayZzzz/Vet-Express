import '../header.dart';

class BranchResponse {
  Header? header;
  Body? body;

  BranchResponse({header, body});

  BranchResponse.fromJson(Map<String, dynamic> json) {
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
  List<Data>? data;

  Body({status, message, data});

  Body.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? nameKh;
  String? telephone;
  String? address;
  double? longs;
  double? lats;
  int? type;

  Data({id, name, nameKh, telephone, address, longs, lats, type});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameKh = json['nameKh'];
    telephone = json['telephone'];
    address = json['address'];
    longs = json['longs'];
    lats = json['lats'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['nameKh'] = nameKh;
    data['telephone'] = telephone;
    data['address'] = address;
    data['longs'] = longs;
    data['lats'] = lats;
    data['type'] = type;
    return data;
  }
}
