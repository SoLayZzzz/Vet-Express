class UploadImage {
  String? img;

  UploadImage({this.img});

  factory UploadImage.fromJson(Map<String, dynamic> json) =>
      UploadImage(img: json["img"]);

  Map<String, dynamic> toJson() => {"img": img};
}
