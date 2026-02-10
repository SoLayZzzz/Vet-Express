import '../../../../../models/header.dart';

class CheckTokenResponse {
  CheckTokenResponse({required this.header});

  Header header;

  factory CheckTokenResponse.fromJson(Map<String, dynamic> json) =>
      CheckTokenResponse(header: Header.fromJson(json["header"]));

  Map<String, dynamic> toJson() => {"header": header.toJson()};
}
