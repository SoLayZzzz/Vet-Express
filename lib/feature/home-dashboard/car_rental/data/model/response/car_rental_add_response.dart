import '../../../../../../models/header.dart';

class CarRentalAddResponse {
  Header? header;
  CarRentalAddResponseBody? body;

  CarRentalAddResponse({this.header, this.body});

  CarRentalAddResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
    body =
        json['body'] != null
            ? CarRentalAddResponseBody.fromJson(json['body'])
            : null;
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

class CarRentalAddResponseBody {
  bool? status;
  String? message;

  CarRentalAddResponseBody({this.status, this.message});

  CarRentalAddResponseBody.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}
