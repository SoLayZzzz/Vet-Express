class ScheduleResponse {
  Header? header;
  List<Body>? body;

  ScheduleResponse({this.header, this.body});

  ScheduleResponse.fromJson(Map<String, dynamic> json) {
    try {
      header =
          json['header'] != null ? new Header.fromJson(json['header']) : null;
      if (json['body'] != null) {
        body = <Body>[];
        json['body'].forEach((v) {
          body!.add(new Body.fromJson(v));
        });
      }
    } catch (e, stack) {
      print('ScheduleResponse.fromJson error: $e');
      print(stack);
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.header != null) {
      data['header'] = this.header!.toJson();
    }
    if (this.body != null) {
      data['body'] = this.body!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;
  String? errorCode;
  String? errorText;
  String? token;
  Pagination? pagination;

  Header({
    this.serverTimestamp,
    this.result,
    this.statusCode,
    this.errorCode,
    this.errorText,
    this.token,
    this.pagination,
  });

  Header.fromJson(Map<String, dynamic> json) {
    serverTimestamp = json['serverTimestamp'];
    result = json['result'];
    statusCode = json['statusCode'];
    errorCode = json['errorCode'];
    errorText = json['errorText'];
    token = json['token'];
    pagination =
        json['pagination'] != null
            ? new Pagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serverTimestamp'] = this.serverTimestamp;
    data['result'] = this.result;
    data['statusCode'] = this.statusCode;
    data['errorCode'] = this.errorCode;
    data['errorText'] = this.errorText;
    data['token'] = this.token;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class Pagination {
  int? page;
  int? rowsPerPage;
  int? total;

  Pagination({this.page, this.rowsPerPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    rowsPerPage = json['rowsPerPage'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    data['rowsPerPage'] = this.rowsPerPage;
    data['total'] = this.total;
    return data;
  }
}

class Body {
  int? steward;
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
  double? discount;
  String? disPercent;
  int? isflashSale;
  int? seatType;

  Body({
    this.steward,
    this.id,
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
  });

  Body.fromJson(Map<String, dynamic> json) {
    steward = json['steward'];
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
    airCon = json['airCon'];
    wc = json['wc'];
    snack = json['snack'];
    wifi = json['wifi'];
    transportationType = json['transportationType'];
    price = (json['price'] as num?)?.toDouble();
    priceForeigner = (json['priceForeigner'] as num?)?.toDouble();
    totalSeat = json['totalSeat'];
    seatAvailable = json['seatAvailable'];
    scheduleType = json['scheduleType'];
    nationRoad = json['nationRoad'];
    journeyType = json['journeyType'];
    transportationPhoto = json['transportationPhoto'];
    if (json['slidePhoto'] != null) {
      slidePhoto = <SlidePhoto>[];
      json['slidePhoto'].forEach((v) {
        slidePhoto!.add(new SlidePhoto.fromJson(v));
      });
    }
    if (json['amenities'] != null) {
      amenities = <Amenities>[];
      json['amenities'].forEach((v) {
        amenities!.add(new Amenities.fromJson(v));
      });
    }
    if (json['boardingPointList'] != null) {
      boardingPointList = <BoardingPointList>[];
      json['boardingPointList'].forEach((v) {
        boardingPointList!.add(new BoardingPointList.fromJson(v));
      });
    }
    if (json['dropOffPointList'] != null) {
      dropOffPointList = <DropOffPointList>[];
      json['dropOffPointList'].forEach((v) {
        dropOffPointList!.add(new DropOffPointList.fromJson(v));
      });
    }
    note = json['note'];
    priceOriginal = json['priceOriginal'];
    status = json['status'];
    totalRate = (json['totalRate'] as num?)?.toDouble();
    totalReview = json['totalReview'];
    scheduleId = json['scheduleId'];
    vehicleType = json['vehicleType'];
    discount = (json['discount'] as num?)?.toDouble();
    disPercent = json['disPercent'];
    isflashSale = json['isflashSale'];
    seatType = json['seatType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['steward'] = this.steward;
    data['id'] = this.id;
    data['description'] = this.description;
    data['departure'] = this.departure;
    data['arrival'] = this.arrival;
    data['duration'] = this.duration;
    data['boardingPoint'] = this.boardingPoint;
    data['boardingPointLongs'] = this.boardingPointLongs;
    data['boardingPointLats'] = this.boardingPointLats;
    data['boardingPointId'] = this.boardingPointId;
    data['dropOffPoint'] = this.dropOffPoint;
    data['dropOffPointLongs'] = this.dropOffPointLongs;
    data['dropOffPointLats'] = this.dropOffPointLats;
    data['dropOffPointId'] = this.dropOffPointId;
    data['airCon'] = this.airCon;
    data['wc'] = this.wc;
    data['snack'] = this.snack;
    data['wifi'] = this.wifi;
    data['transportationType'] = this.transportationType;
    data['price'] = this.price;
    data['priceForeigner'] = this.priceForeigner;
    data['totalSeat'] = this.totalSeat;
    data['seatAvailable'] = this.seatAvailable;
    data['scheduleType'] = this.scheduleType;
    data['nationRoad'] = this.nationRoad;
    data['journeyType'] = this.journeyType;
    data['transportationPhoto'] = this.transportationPhoto;
    if (this.slidePhoto != null) {
      data['slidePhoto'] = this.slidePhoto!.map((v) => v.toJson()).toList();
    }
    if (this.amenities != null) {
      data['amenities'] = this.amenities!.map((v) => v.toJson()).toList();
    }
    if (this.boardingPointList != null) {
      data['boardingPointList'] =
          this.boardingPointList!.map((v) => v.toJson()).toList();
    }
    if (this.dropOffPointList != null) {
      data['dropOffPointList'] =
          this.dropOffPointList!.map((v) => v.toJson()).toList();
    }
    data['note'] = this.note;
    data['priceOriginal'] = this.priceOriginal;
    data['status'] = this.status;
    data['totalRate'] = this.totalRate;
    data['totalReview'] = this.totalReview;
    data['scheduleId'] = this.scheduleId;
    data['vehicleType'] = this.vehicleType;
    data['discount'] = this.discount;
    data['disPercent'] = this.disPercent;
    data['isflashSale'] = this.isflashSale;
    data['seatType'] = this.seatType;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photo'] = this.photo;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['name'] = this.name;
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

  BoardingPointList({
    this.id,
    this.name,
    this.address,
    this.longs,
    this.lats,
    this.time,
  });

  BoardingPointList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    longs = json['longs'];
    lats = json['lats'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['longs'] = this.longs;
    data['lats'] = this.lats;
    data['time'] = this.time;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['longs'] = this.longs;
    data['lats'] = this.lats;
    return data;
  }
}
