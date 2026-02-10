import '../../../../models/seat/seat_unavailable.dart';
import '../repository/seat_repository.dart';

class SelectSeatUseCase {
  final SeatRepository seatRepository;

  SelectSeatUseCase(this.seatRepository);

  Future<Map<dynamic, dynamic>> fetchSeatLayout({
    required dynamic context,
    required String date,
    required String journeyId,
  }) {
    return seatRepository.getSeatLayout(
      context: context,
      date: date,
      journeyId: journeyId,
    );
  }

  Future<SeatUnavailable> fetchUnavailable({
    required dynamic context,
    required String date,
    required String journeyId,
  }) {
    return seatRepository.getUnavailable(
      context: context,
      date: date,
      journeyId: journeyId,
    );
  }
}
