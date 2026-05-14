import '../../../../../../models/header.dart';

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

// class ScheduleResponse {
//   Header? header;
//   List<ScheduleResponseBody>? body;

//   ScheduleResponse({this.header, this.body});

//   ScheduleResponse.fromJson(Map<String, dynamic> json) {
//     header = json['header'] != null ? Header.fromJson(json['header']) : null;
//     if (json['body'] != null) {
//       body = <ScheduleResponseBody>[];
//       json['body'].forEach((v) {
//         body!.add(ScheduleResponseBody.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (header != null) {
//       data['header'] = header!.toJson();
//     }
//     if (body != null) {
//       data['body'] = body!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class ScheduleResponseBody {
//   int? scheduleId;
//   String? id;
//   String? description;
//   String? departure;
//   String? arrival;
//   String? duration;
//   String? boardingPoint;
//   String? boardingPointLongs;
//   String? boardingPointLats;
//   String? boardingPointId;
//   String? dropOffPoint;
//   String? dropOffPointLongs;
//   String? dropOffPointLats;
//   String? dropOffPointId;
//   int? airCon;
//   int? wc;
//   int? snack;
//   int? wifi;
//   String? transportationType;
//   double? price;
//   double? priceForeigner;
//   String? priceOriginal;
//   int? totalSeat;
//   int? seatAvailable;
//   String? scheduleType;
//   String? nationRoad;
//   int? journeyType;
//   String? transportationPhoto;
//   List<SlidePhoto>? slidePhoto;
//   List<Amenities>? amenities;
//   List<BoardingPointList>? boardingPointList;
//   List<DropOffPointList>? dropOffPointList;
//   String? note;
//   int? status;
//   double? totalRate;
//   int? totalReview;
//   int? vehicleType;
//   int? steward;

//   ScheduleResponseBody({
//     this.scheduleId,
//     this.id,
//     this.description,
//     this.departure,
//     this.arrival,
//     this.duration,
//     this.boardingPoint,
//     this.boardingPointLongs,
//     this.boardingPointLats,
//     this.boardingPointId,
//     this.dropOffPoint,
//     this.dropOffPointLongs,
//     this.dropOffPointLats,
//     this.dropOffPointId,
//     this.airCon,
//     this.wc,
//     this.snack,
//     this.wifi,
//     this.transportationType,
//     this.price,
//     this.priceForeigner,
//     this.priceOriginal,
//     this.totalSeat,
//     this.seatAvailable,
//     this.scheduleType,
//     this.nationRoad,
//     this.journeyType,
//     this.transportationPhoto,
//     this.slidePhoto,
//     this.amenities,
//     this.boardingPointList,
//     this.dropOffPointList,
//     this.note,
//     this.status,
//     this.totalRate,
//     this.totalReview,
//     this.vehicleType,
//     this.steward,
//   });

//   ScheduleResponseBody.fromJson(Map<String, dynamic> json) {
//     scheduleId = json['scheduleId'];
//     id = json['id'];
//     description = json['description'];
//     departure = json['departure'];
//     arrival = json['arrival'];
//     duration = json['duration'];
//     boardingPoint = json['boardingPoint'];
//     boardingPointLongs = json['boardingPointLongs'];
//     boardingPointLats = json['boardingPointLats'];
//     boardingPointId = json['boardingPointId'];
//     dropOffPoint = json['dropOffPoint'];
//     dropOffPointLongs = json['dropOffPointLongs'];
//     dropOffPointLats = json['dropOffPointLats'];
//     dropOffPointId = json['dropOffPointId'];
//     airCon = json['airCon'];
//     wc = json['wc'];
//     snack = json['snack'];
//     wifi = json['wifi'];
//     transportationType = json['transportationType'];
//     price = json['price'];
//     priceForeigner = json['priceForeigner'];
//     priceOriginal = json['priceOriginal'];
//     totalSeat = json['totalSeat'];
//     seatAvailable = json['seatAvailable'];
//     scheduleType = json['scheduleType'];
//     nationRoad = json['nationRoad'];
//     journeyType = json['journeyType'];
//     transportationPhoto = json['transportationPhoto'];
//     if (json['slidePhoto'] != null) {
//       slidePhoto = <SlidePhoto>[];
//       json['slidePhoto'].forEach((v) {
//         slidePhoto!.add(SlidePhoto.fromJson(v));
//       });
//     }
//     if (json['amenities'] != null) {
//       amenities = <Amenities>[];
//       json['amenities'].forEach((v) {
//         amenities!.add(Amenities.fromJson(v));
//       });
//     }
//     if (json['boardingPointList'] != null) {
//       boardingPointList = <BoardingPointList>[];
//       json['boardingPointList'].forEach((v) {
//         boardingPointList!.add(BoardingPointList.fromJson(v));
//       });
//     }
//     if (json['dropOffPointList'] != null) {
//       dropOffPointList = <DropOffPointList>[];
//       json['dropOffPointList'].forEach((v) {
//         dropOffPointList!.add(DropOffPointList.fromJson(v));
//       });
//     }
//     note = json['note'];
//     status = json['status'];
//     totalRate = json['totalRate'];
//     totalReview = json['totalReview'];
//     vehicleType = json['vehicleType'];
//     steward = json['steward'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['scheduleId'] = scheduleId;
//     data['id'] = id;
//     data['description'] = description;
//     data['departure'] = departure;
//     data['arrival'] = arrival;
//     data['duration'] = duration;
//     data['boardingPoint'] = boardingPoint;
//     data['boardingPointLongs'] = boardingPointLongs;
//     data['boardingPointLats'] = boardingPointLats;
//     data['boardingPointId'] = boardingPointId;
//     data['dropOffPoint'] = dropOffPoint;
//     data['dropOffPointLongs'] = dropOffPointLongs;
//     data['dropOffPointLats'] = dropOffPointLats;
//     data['dropOffPointId'] = dropOffPointId;
//     data['airCon'] = airCon;
//     data['wc'] = wc;
//     data['snack'] = snack;
//     data['wifi'] = wifi;
//     data['transportationType'] = transportationType;
//     data['price'] = price;
//     data['priceForeigner'] = priceForeigner;
//     data['priceOriginal'] = priceOriginal;
//     data['totalSeat'] = totalSeat;
//     data['seatAvailable'] = seatAvailable;
//     data['scheduleType'] = scheduleType;
//     data['nationRoad'] = nationRoad;
//     data['journeyType'] = journeyType;
//     data['transportationPhoto'] = transportationPhoto;
//     if (slidePhoto != null) {
//       data['slidePhoto'] = slidePhoto!.map((v) => v.toJson()).toList();
//     }
//     if (amenities != null) {
//       data['amenities'] = amenities!.map((v) => v.toJson()).toList();
//     }
//     if (boardingPointList != null) {
//       data['boardingPointList'] =
//           boardingPointList!.map((v) => v.toJson()).toList();
//     }
//     if (dropOffPointList != null) {
//       data['dropOffPointList'] =
//           dropOffPointList!.map((v) => v.toJson()).toList();
//     }
//     data['note'] = note;
//     data['status'] = status;
//     data['totalRate'] = totalRate;
//     data['totalReview'] = totalReview;
//     data['vehicleType'] = vehicleType;
//     data['steward'] = steward;
//     return data;
//   }
// }

// class BoardingPointList {
//   String? id;
//   String? name;
//   String? address;
//   String? longs;
//   String? lats;

//   BoardingPointList({this.id, this.name, this.address, this.longs, this.lats});

//   BoardingPointList.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     address = json['address'];
//     longs = json['longs'];
//     lats = json['lats'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['address'] = address;
//     data['longs'] = longs;
//     data['lats'] = lats;
//     return data;
//   }
// }

// class DropOffPointList {
//   String? id;
//   String? name;
//   String? address;
//   String? longs;
//   String? lats;

//   DropOffPointList({this.id, this.name, this.address, this.longs, this.lats});

//   DropOffPointList.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     address = json['address'];
//     longs = json['longs'];
//     lats = json['lats'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['address'] = address;
//     data['longs'] = longs;
//     data['lats'] = lats;
//     return data;
//   }
// }

// class SlidePhoto {
//   String? photo;

//   SlidePhoto({this.photo});

//   SlidePhoto.fromJson(Map<String, dynamic> json) {
//     photo = json['photo'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['photo'] = photo;
//     return data;
//   }
// }

// class Amenities {
//   String? icon;
//   String? name;

//   Amenities({this.icon, this.name});

//   Amenities.fromJson(Map<String, dynamic> json) {
//     icon = json['icon'];
//     name = json['name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['icon'] = icon;
//     data['name'] = name;
//     return data;
//   }
// }

class ScheduleResponse {
  Header? header;
  List<ScheduleResponseBody>? body;

  ScheduleResponse({this.header, this.body});

  ScheduleResponse.fromJson(Map<String, dynamic> json) {
    header =
        json['header'] != null ? Header.fromJson(json['header']) : null;
    if (json['body'] != null) {
      body = <ScheduleResponseBody>[];
      json['body'].forEach((v) {
        body!.add(ScheduleResponseBody.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (header != null) {
      data['header'] = header!.toJson();
    }
    if (body != null) {
      data['body'] = body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({this.serverTimestamp, this.result, this.statusCode});

  Header.fromJson(Map<String, dynamic> json) {
    serverTimestamp = _asInt(json['serverTimestamp']);
    result = json['result'];
    statusCode = _asInt(json['statusCode']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['serverTimestamp'] = serverTimestamp;
    data['result'] = result;
    data['statusCode'] = statusCode;
    return data;
  }
}

class ScheduleResponseBody {
  String? id;
  String? description;
  String? departure;
  String? arrival;
  String? duration;
  String? boardingPoint;
  String? boardingPointLongs;
  String? boardingPointLats;
  String? boardingPointId;
  String? dropOffPoint;
  String? dropOffPointLongs;
  String? dropOffPointLats;
  String? dropOffPointId;
  int? airCon;
  int? wc;
  int? snack;
  int? wifi;
  String? transportationType;
  double? price;
  double? priceForeigner;
  int? totalSeat;
  int? seatAvailable;
  String? scheduleType;
  String? nationRoad;
  int? journeyType;
  String? transportationPhoto;
  List<SlidePhoto>? slidePhoto;
  List<Amenities>? amenities;
  List<BoardingPointList>? boardingPointList;
  List<DropOffPointList>? dropOffPointList;
  String? note;
  String? priceOriginal;
  int? status;
  double? totalRate;
  int? totalReview;
  int? scheduleId;
  int? vehicleType;
  int? discount;
  String? disPercent;
  int? isflashSale;
  int? seatType;
  int? steward;

  ScheduleResponseBody(
      {this.id,
      this.description,
      this.departure,
      this.arrival,
      this.duration,
      this.boardingPoint,
      this.boardingPointLongs,
      this.boardingPointLats,
      this.boardingPointId,
      this.dropOffPoint,
      this.dropOffPointLongs,
      this.dropOffPointLats,
      this.dropOffPointId,
      this.airCon,
      this.wc,
      this.snack,
      this.wifi,
      this.transportationType,
      this.price,
      this.priceForeigner,
      this.totalSeat,
      this.seatAvailable,
      this.scheduleType,
      this.nationRoad,
      this.journeyType,
      this.transportationPhoto,
      this.slidePhoto,
      this.amenities,
      this.boardingPointList,
      this.dropOffPointList,
      this.note,
      this.priceOriginal,
      this.status,
      this.totalRate,
      this.totalReview,
      this.scheduleId,
      this.vehicleType,
      this.discount,
      this.disPercent,
      this.isflashSale,
      this.seatType,
      this.steward});

  ScheduleResponseBody.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    departure = json['departure'];
    arrival = json['arrival'];
    duration = json['duration'];
    boardingPoint = json['boardingPoint'];
    boardingPointLongs = json['boardingPointLongs'];
    boardingPointLats = json['boardingPointLats'];
    boardingPointId = json['boardingPointId'];
    dropOffPoint = json['dropOffPoint'];
    dropOffPointLongs = json['dropOffPointLongs'];
    dropOffPointLats = json['dropOffPointLats'];
    dropOffPointId = json['dropOffPointId'];
    airCon = _asInt(json['airCon']);
    wc = _asInt(json['wc']);
    snack = _asInt(json['snack']);
    wifi = _asInt(json['wifi']);
    transportationType = json['transportationType'];
    price = _asDouble(json['price']);
    priceForeigner = _asDouble(json['priceForeigner']);
    totalSeat = _asInt(json['totalSeat']);
    seatAvailable = _asInt(json['seatAvailable']);
    scheduleType = json['scheduleType'];
    nationRoad = json['nationRoad'];
    journeyType = _asInt(json['journeyType']);
    transportationPhoto = json['transportationPhoto'];
    if (json['slidePhoto'] != null) {
      slidePhoto = <SlidePhoto>[];
      json['slidePhoto'].forEach((v) {
        slidePhoto!.add(SlidePhoto.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      json['amenities'].forEach((v) {
        amenities!.add(Amenities.fromJson(v));
      });
    }
    if (json['boardingPointList'] != null) {
      boardingPointList = <BoardingPointList>[];
      json['boardingPointList'].forEach((v) {
        boardingPointList!.add(BoardingPointList.fromJson(v));
      });
    }
    if (json['dropOffPointList'] != null) {
      dropOffPointList = <DropOffPointList>[];
      json['dropOffPointList'].forEach((v) {
        dropOffPointList!.add(DropOffPointList.fromJson(v));
      });
    }
    note = json['note'];
    priceOriginal = json['priceOriginal'];
    status = _asInt(json['status']);
    totalRate = _asDouble(json['totalRate']);
    totalReview = _asInt(json['totalReview']);
    scheduleId = _asInt(json['scheduleId']);
    vehicleType = _asInt(json['vehicleType']);
    discount = _asInt(json['discount']);
    disPercent = json['disPercent'];
    isflashSale = _asInt(json['isflashSale']);
    seatType = _asInt(json['seatType']);
    steward = _asInt(json['steward']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['departure'] = departure;
    data['arrival'] = arrival;
    data['duration'] = duration;
    data['boardingPoint'] = boardingPoint;
    data['boardingPointLongs'] = boardingPointLongs;
    data['boardingPointLats'] = boardingPointLats;
    data['boardingPointId'] = boardingPointId;
    data['dropOffPoint'] = dropOffPoint;
    data['dropOffPointLongs'] = dropOffPointLongs;
    data['dropOffPointLats'] = dropOffPointLats;
    data['dropOffPointId'] = dropOffPointId;
    data['airCon'] = airCon;
    data['wc'] = wc;
    data['snack'] = snack;
    data['wifi'] = wifi;
    data['transportationType'] = transportationType;
    data['price'] = price;
    data['priceForeigner'] = priceForeigner;
    data['totalSeat'] = totalSeat;
    data['seatAvailable'] = seatAvailable;
    data['scheduleType'] = scheduleType;
    data['nationRoad'] = nationRoad;
    data['journeyType'] = journeyType;
    data['transportationPhoto'] = transportationPhoto;
    if (slidePhoto != null) {
      data['slidePhoto'] = slidePhoto!.map((v) => v.toJson()).toList();
    }
    if (amenities != null) {
      data['amenities'] = amenities!.map((v) => v.toJson()).toList();
    }
    if (boardingPointList != null) {
      data['boardingPointList'] =
          boardingPointList!.map((v) => v.toJson()).toList();
    }
    if (dropOffPointList != null) {
      data['dropOffPointList'] =
          dropOffPointList!.map((v) => v.toJson()).toList();
    }
    data['note'] = note;
    data['priceOriginal'] = priceOriginal;
    data['status'] = status;
    data['totalRate'] = totalRate;
    data['totalReview'] = totalReview;
    data['scheduleId'] = scheduleId;
    data['vehicleType'] = vehicleType;
    data['discount'] = discount;
    data['disPercent'] = disPercent;
    data['isflashSale'] = isflashSale;
    data['seatType'] = seatType;
    data['steward'] = steward;
    return data;
  }
}

class SlidePhoto {
  String? photo;

  SlidePhoto({this.photo});

  SlidePhoto.fromJson(Map<String, dynamic> json) {
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['photo'] = photo;
    return data;
  }
}

class Amenities {
  String? icon;
  String? name;

  Amenities({this.icon, this.name});

  Amenities.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['icon'] = icon;
    data['name'] = name;
    return data;
  }
}

class BoardingPointList {
  String? id;
  String? name;
  String? address;
  String? longs;
  String? lats;
  String? time;

  BoardingPointList(
      {this.id, this.name, this.address, this.longs, this.lats, this.time});

  BoardingPointList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    longs = json['longs'];
    lats = json['lats'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['longs'] = longs;
    data['lats'] = lats;
    data['time'] = time;
    return data;
  }
}

class DropOffPointList {
  String? id;
  String? name;
  String? address;
  String? longs;
  String? lats;

  DropOffPointList({this.id, this.name, this.address, this.longs, this.lats});

  DropOffPointList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    longs = json['longs'];
    lats = json['lats'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['longs'] = longs;
    data['lats'] = lats;
    return data;
  }
}
