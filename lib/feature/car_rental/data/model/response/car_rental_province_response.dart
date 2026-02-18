import '../../../../../models/header.dart';

class CarRentalProvinceResponse {
  Header? header;
  CarRentalProvinceBody? body;

  CarRentalProvinceResponse({this.header, this.body});

  CarRentalProvinceResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
    body =
        json['body'] != null
            ? CarRentalProvinceBody.fromJson(json['body'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    if (header != null) {
      out['header'] = header!.toJson();
    }
    if (body != null) {
      out['body'] = body!.toJson();
    }
    return out;
  }
}

class CarRentalProvinceBody {
  bool? status;
  String? message;
  List<CarRentalProvinceData>? data;

  CarRentalProvinceBody({this.status, this.message, this.data});

  CarRentalProvinceBody.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message'] as String?;

    if (json['data'] != null) {
      data = <CarRentalProvinceData>[];
      (json['data'] as List<dynamic>).forEach((v) {
        data!.add(CarRentalProvinceData.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    out['status'] = status;
    out['message'] = message;
    if (data != null) {
      out['data'] = data!.map((v) => v.toJson()).toList();
    }
    return out;
  }
}

class CarRentalProvinceData {
  int? id;
  String? name;

  CarRentalProvinceData({this.id, this.name});

  CarRentalProvinceData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    out['id'] = id;
    out['name'] = name;
    return out;
  }
}
