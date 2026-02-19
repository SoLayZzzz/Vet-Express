class ScheduleRequestBody {
  final String date;
  final String fromId;
  final String toId;
  final String type;
  final String app;
  final String national;

  ScheduleRequestBody({
    required this.date,
    required this.fromId,
    required this.toId,
    required this.type,
    required this.app,
    required this.national,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'destinationFrom': fromId,
      'destinationTo': toId,
      'type': type,
      'app': app,
      'nationally': national,
    };
  }

  Map<String, String> toFormFields() {
    return <String, String>{
      'date': date,
      'destinationFrom': fromId,
      'destinationTo': toId,
      'type': type,
      'app': app,
      'nationally': national,
    };
  }
}
