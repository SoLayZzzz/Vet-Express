import '../../../../../models/header.dart';

class CheckVersionResponse {
  Header? header;
  Body? body;

  CheckVersionResponse({this.header, this.body});

  factory CheckVersionResponse.fromJson(Map<String, dynamic> json) =>
      CheckVersionResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : Body.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class Body {
  double? version;
  double? android;
  double? ios;
  List<Cache>? cache;

  Body({this.version, this.android, this.ios, this.cache});

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    version: json["version"]?.toDouble(),
    android: json["android"]?.toDouble(),
    ios: json["ios"]?.toDouble(),
    cache:
        json["cache"] == null
            ? []
            : List<Cache>.from(json["cache"]!.map((x) => Cache.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "version": version,
    "android": android,
    "ios": ios,
    "cache":
        cache == null ? [] : List<dynamic>.from(cache!.map((x) => x.toJson())),
  };
}

class Cache {
  String? name;
  int? modified;

  Cache({this.name, this.modified});

  factory Cache.fromJson(Map<String, dynamic> json) =>
      Cache(name: json["name"], modified: json["modified"]);

  Map<String, dynamic> toJson() => {"name": name, "modified": modified};
}
