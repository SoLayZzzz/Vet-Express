import '../../../../../../models/header.dart';

class DestinationResponse {
  final Header? header;
  final List<DestinationItem>? body;

  DestinationResponse({this.header, this.body});

  factory DestinationResponse.fromJson(Map<String, dynamic> json) {
    return DestinationResponse(
      header: json['header'] != null ? Header.fromJson(json['header']) : null,
      body:
          json['body'] != null
              ? List<DestinationItem>.from(
                (json['body'] as List<dynamic>).map(
                  (x) => DestinationItem.fromJson(x as Map<String, dynamic>),
                ),
              )
              : null,
    );
  }
}

class DestinationItem {
  final String? id;
  final String? name;

  DestinationItem({this.id, this.name});

  factory DestinationItem.fromJson(Map<String, dynamic> json) {
    return DestinationItem(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }
}
