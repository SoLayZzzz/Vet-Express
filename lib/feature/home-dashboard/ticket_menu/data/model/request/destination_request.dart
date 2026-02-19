class DestinationsFromRequest {
  final String lang;
  final String type;
  final String searchText;

  DestinationsFromRequest({
    required this.lang,
    required this.type,
    required this.searchText,
  });

  Map<String, String> toFields() => {
    'lang': lang,
    'type': type,
    'searchText': searchText,
  };
}

class DestinationsToRequest {
  final String fromId;
  final String lang;
  final String type;
  final String searchText;

  DestinationsToRequest({
    required this.fromId,
    required this.lang,
    required this.type,
    required this.searchText,
  });

  Map<String, String> toFields() => {
    'fromId': fromId,
    'lang': lang,
    'type': type,
    'searchText': searchText,
  };
}
