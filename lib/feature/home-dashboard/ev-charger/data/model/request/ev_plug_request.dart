class EvPlugRequest {
  final String chargerUserName;

  EvPlugRequest({
    required this.chargerUserName,
  });

  Map<String, dynamic> toJson() {
    return {
      'chargerUserName': chargerUserName
    };
  }

  Map<String, String> toFormFields() {
    return <String, String>{
      'chargerUserName': chargerUserName
    };
  }
}
