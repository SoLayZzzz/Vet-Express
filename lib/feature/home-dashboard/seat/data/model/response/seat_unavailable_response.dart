import '../../../../../../models/header.dart';

class SeatUnavailableResponse {
  Header? header;
  List<Body>? body;

  SeatUnavailableResponse({header, body});

  SeatUnavailableResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
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
  String? seatNumber;
  String? gender;
  int? status;

  Body({seatNumber, gender, status});

  Body.fromJson(Map<String, dynamic> json) {
    seatNumber = json['seatNumber'];
    gender = json['gender'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seatNumber'] = seatNumber;
    data['gender'] = gender;
    data['status'] = status;
    return data;
  }
}
