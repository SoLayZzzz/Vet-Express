// import '../header.dart';
//
// class DestinationResponse {
//   Header? header;
//   List<Body>? body;
//
//   DestinationResponse({header, body});
//
//   DestinationResponse.fromJson(Map<String, dynamic> json) {
//     header = json['header'] != null ? Header.fromJson(json['header']) : null;
//     if (json['body'] != null) {
//       body = <Body>[];
//       json['body'].forEach((v) {
//         body!.add(Body.fromJson(v));
//       });
//     }
//   }
//
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
//
// class Body {
//   String? id;
//   String? name;
//
//   Body({id, name});
//
//   Body.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     return data;
//   }
// }

import '../header.dart';

class DestinationResponse {
  final Header? header;
  final List<Body>? body;

  DestinationResponse({this.header, this.body});

  factory DestinationResponse.fromJson(Map<String, dynamic> json) {
    return DestinationResponse(
      header: json['header'] != null ? Header.fromJson(json['header']) : null,
      body:
          json['body'] != null ? List<Body>.from(json['body'].map((x) => Body.fromJson(x))) : null,
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
