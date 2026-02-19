import 'dart:convert';

class CheckBookingPackageRequest {
  final dynamic context;
  final String code;
  final String journeyId;
  final String travelDate;

  CheckBookingPackageRequest({
    required this.context,
    required this.code,
    required this.journeyId,
    required this.travelDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'context': context,
      'code': code,
      'journey_id': journeyId,
      'travel_date': travelDate,
    };
  }

  String toJson() => json.encode(toMap());

  factory CheckBookingPackageRequest.fromMap(Map<String, dynamic> map) {
    return CheckBookingPackageRequest(
      context: map['context'],
      code: map['code'] ?? '',
      journeyId: map['journey_id'] ?? '',
      travelDate: map['travel_date'] ?? '',
    );
  }
}
