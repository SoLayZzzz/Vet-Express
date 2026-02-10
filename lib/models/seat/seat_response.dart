

import '../header.dart';

class SeatResponse {
  Header? header;
  List<Body>? body;

  SeatResponse({header, body});

  SeatResponse.fromJson(Map<String, dynamic> json) {
    header =
    json['header'] != null ?  Header.fromJson(json['header']) : null;
    if (json['body'] != null) {
      body = <Body>[];
      json['body'].forEach((v) {
        body!.add( Body.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
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
  String? layout;
  int? seatType;

  Body({layout, seatType});

  Body.fromJson(Map<String, dynamic> json) {
    layout = json['layout'];
    seatType = json['seatType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['layout'] = layout;
    data['seatType'] = seatType;
    return data;
  }
}