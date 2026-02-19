import '../../../../../../models/header.dart';

class CarRentalCarTypeResponse {
  Header? header;
  CarRentalCarTypeBody? body;

  CarRentalCarTypeResponse({this.header, this.body});

  CarRentalCarTypeResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
    body =
        json['body'] != null
            ? CarRentalCarTypeBody.fromJson(json['body'])
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

class CarRentalCarTypeBody {
  bool? status;
  String? message;
  List<CarRentalCarTypeData>? data;

  CarRentalCarTypeBody({this.status, this.message, this.data});

  CarRentalCarTypeBody.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool?;
    message = json['message'] as String?;

    if (json['data'] != null) {
      data = <CarRentalCarTypeData>[];
      (json['data'] as List<dynamic>).forEach((v) {
        data!.add(CarRentalCarTypeData.fromJson(v as Map<String, dynamic>));
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

class CarRentalCarTypeData {
  int? id;
  String? name;
  String? totalSeat;
  String? photo;
  List<CarRentalSlidePhoto>? slidePhoto;
  List<CarRentalAmenities>? amenities;

  CarRentalCarTypeData({
    this.id,
    this.name,
    this.totalSeat,
    this.photo,
    this.slidePhoto,
    this.amenities,
  });

  CarRentalCarTypeData.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
    totalSeat = json['totalSeat']?.toString();
    photo = json['photo']?.toString();

    if (json['slidePhoto'] != null) {
      slidePhoto = <CarRentalSlidePhoto>[];
      (json['slidePhoto'] as List<dynamic>).forEach((v) {
        slidePhoto!.add(
          CarRentalSlidePhoto.fromJson(v as Map<String, dynamic>),
        );
      });
    }
    if (json['amenities'] != null) {
      amenities = <CarRentalAmenities>[];
      (json['amenities'] as List<dynamic>).forEach((v) {
        amenities!.add(CarRentalAmenities.fromJson(v as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    out['id'] = id;
    out['name'] = name;
    out['totalSeat'] = totalSeat;
    out['photo'] = photo;
    if (slidePhoto != null) {
      out['slidePhoto'] = slidePhoto!.map((v) => v.toJson()).toList();
    }
    if (amenities != null) {
      out['amenities'] = amenities!.map((v) => v.toJson()).toList();
    }
    return out;
  }
}

class CarRentalSlidePhoto {
  String? photo;

  CarRentalSlidePhoto({this.photo});

  CarRentalSlidePhoto.fromJson(Map<String, dynamic> json) {
    photo = json['photo']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    out['photo'] = photo;
    return out;
  }
}

class CarRentalAmenities {
  String? icon;
  String? name;

  CarRentalAmenities({this.icon, this.name});

  CarRentalAmenities.fromJson(Map<String, dynamic> json) {
    icon = json['icon']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> out = <String, dynamic>{};
    out['icon'] = icon;
    out['name'] = name;
    return out;
  }
}
