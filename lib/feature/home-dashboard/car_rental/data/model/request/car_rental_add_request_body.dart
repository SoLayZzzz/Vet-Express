class CarRentalAddRequestBody {
  final String busTypeId;
  final String dateFrom;
  final String dateTo;
  final String name;
  final String numberBus;
  final String provinceFrom;
  final String provinceTo;
  final String telephone;
  final String travelType;
  final String note;

  CarRentalAddRequestBody({
    required this.busTypeId,
    required this.dateFrom,
    required this.dateTo,
    required this.name,
    required this.numberBus,
    required this.provinceFrom,
    required this.provinceTo,
    required this.telephone,
    required this.travelType,
    required this.note,
  });

  Map<String, String> toFormFields() {
    return <String, String>{
      'busTypeId': busTypeId,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
      'name': name,
      'numberBus': numberBus,
      'provinceFrom': provinceFrom,
      'provinceTo': provinceTo,
      'telephone': telephone,
      'travelType': travelType,
      'note': note,
    };
  }
}
