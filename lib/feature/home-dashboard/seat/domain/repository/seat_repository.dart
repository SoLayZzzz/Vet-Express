import '../../data/model/response/seat_unavailable_response.dart';

abstract class SeatRepository {
  Future<Map<dynamic, dynamic>> getSeatLayout({
    required dynamic context,
    required String date,
    required String journeyId,
  });

  Future<SeatUnavailableResponse> getUnavailable({
    required dynamic context,
    required String date,
    required String journeyId,
  });
}
