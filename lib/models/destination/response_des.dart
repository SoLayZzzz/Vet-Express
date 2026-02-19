import '../header.dart';

class DestinationResponse {
  final Header? header;
  final List<Body>? body;

  DestinationResponse({this.header, this.body});

  factory DestinationResponse.fromJson(Map<String, dynamic> json) {
    return DestinationResponse(
      header: json['header'] != null ? Header.fromJson(json['header']) : null,
      body:
          json['body'] != null
              ? List<Body>.from(json['body'].map((x) => Body.fromJson(x)))
              : null,
    );
  }
}

class Body {
  final String? id;
  final String? name;

  Body({this.id, this.name});

  factory Body.fromJson(Map<String, dynamic> json) {
    return Body(
      id: json['id']?.toString(), // Convert to string if needed
      name: json['name'],
    );
  }
}
