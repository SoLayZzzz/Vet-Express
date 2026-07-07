import 'dart:convert';

ChoosePaymentResponse choosePaymentResponseFromJson(String str) => ChoosePaymentResponse.fromJson(json.decode(str));

String choosePaymentResponseToJson(ChoosePaymentResponse data) => json.encode(data.toJson());

class ChoosePaymentResponse {
    bool status;
    Data data;

    ChoosePaymentResponse({
        required this.status,
        required this.data,
    });

    factory ChoosePaymentResponse.fromJson(Map<String, dynamic> json) => ChoosePaymentResponse(
        status: json["status"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
    };
}

class Data {
    bool status;
    String message;
    List<Datum> data;

    Data({
        required this.status,
        required this.message,
        required this.data,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String name;
    int status;

    Datum({
        required this.name,
        required this.status,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json["name"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
    };
}