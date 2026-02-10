import '../../../../models/seat/seat_unavailable.dart';

abstract class SeatRepository {
  Future<Map<dynamic, dynamic>> getSeatLayout({
    required dynamic context,
    required String date,
    required String journeyId,
  });

  Future<SeatUnavailable> getUnavailable({
    required dynamic context,
    required String date,
    required String journeyId,
  });
}
