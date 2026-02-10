import '../header.dart';

class UserMeResponse {
  Header? header;
  Body? body;

  UserMeResponse({header, body});

  UserMeResponse.fromJson(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
    body = json['body'] != null ? Body.fromJson(json['body']) : null;
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

class Body {
  String? name;
  String? username;
  String? telephone;
  String? email;
  String? filename;
  String? dob;
  int? nationalityId;
  String? nationalityName;
  int? gender;

  Body({name, username, telephone, email, filename});

  Body.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    username = json['username'];
    telephone = json['telephone'];
    email = json['email'];
    filename = json['filename'];
    dob = json['dob'];
    nationalityId = json['nationalityId'];
    nationalityName = json['nationalityName'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['username'] = username;
    data['telephone'] = telephone;
    data['email'] = email;
    data['filename'] = filename;
    data['dob'] = dob;
    data['nationalityId'] = nationalityId;
    data['nationalityName'] = nationalityName;
    data['gender'] = gender;
    return data;
  }
}
