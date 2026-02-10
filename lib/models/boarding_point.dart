
import 'header.dart';

class CarPointResponse {
  Header? header;
  List<Body>? body;

  CarPointResponse({this.header, this.body});

  CarPointResponse.fromJson(Map<String, dynamic> json) {
    header =
    json['header'] != null ? Header.fromJson(json['header']) : null;
    if (json['body'] != null) {
      body = <Body>[];
      json['body'].forEach((v) {
        body!.add(Body.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (header != null) {
      data['header'] = header!.toJson();
    }
    if (body != null) {
      data['body'] = body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Body {
  String? id;
  String? name;
  String? address;
  String? longs;
  String? lats;
  int? isAllow;

  Body({this.id, this.name, this.address, this.longs, this.lats, this.isAllow});

  Body.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    longs = json['longs'];
    lats = json['lats'];
    isAllow = json['isAllow'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['longs'] = longs;
    data['lats'] = lats;
    data['isAllow'] = isAllow;
    return data;
  }
}