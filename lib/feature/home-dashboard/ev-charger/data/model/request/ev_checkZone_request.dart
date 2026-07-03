class EvCheckZoneRequest {
  final String lats;
  final String longs;
  final String? chargerUsername;
  final String? chargerUserName;

  EvCheckZoneRequest({
    required this.lats,
    required this.longs,
    this.chargerUsername,
    this.chargerUserName,
  });

  Map<String, dynamic> toJson() {
    return {
      'lats': lats,
      'longs': longs,
      if (chargerUsername != null) 'chargerUsername': chargerUsername,
      if (chargerUserName != null) 'chargerUserName': chargerUserName,
    };
  }

  Map<String, String> toFormFields() {
    return <String, String>{
      'lats': lats,
      'longs': longs,
      if (chargerUsername != null) 'chargerUsername': chargerUsername!,
      if (chargerUserName != null) 'chargerUserName': chargerUserName!,
    };
  }
}
