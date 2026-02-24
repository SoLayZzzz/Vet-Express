class RegisterRequest {
  String? name;
  String? password;
  String? telephone;
  String? email;
  String? dob;
  String? filename;
  int? gender;
  int? nationalityId;

  // Constructor
  RegisterRequest({
    this.name,
    this.password,
    this.telephone,
    this.email,
    this.dob,
    this.filename,
    this.gender,
    this.nationalityId,
  });

  // Convert JSON Map to RegisterRequest object
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      name: json['name'],
      password: json['password'],
      telephone: json['telephone'],
      email: json['email'],
      dob: json['dob'],
      filename: json['filename'],
      gender: json['gender'],
      nationalityId: json['nationalityId'],
    );
  }

  // Convert RegisterRequest object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
      'telephone': telephone,
      'email': email,
      'dob': dob,
      'filename': filename,
      'gender': gender,
      'nationalityId': nationalityId,
    };
  }
}
