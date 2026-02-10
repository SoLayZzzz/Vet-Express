import '../../domain/repository/seat_repository.dart';
import '../../../../models/seat/seat_unavailable.dart';
import '../network/seat_network_request.dart';

class SeatRepositoryImpl implements SeatRepository {
  final SeatNetworkRequest seatNetworkRequest;

  SeatRepositoryImpl(this.seatNetworkRequest);

  @override
  Future<Map<dynamic, dynamic>> getSeatLayout({
    required context,
    required String date,
    required String journeyId,
  }) {
    return seatNetworkRequest.getSeatLayout(
      context: context,
      date: date,
      journeyId: journeyId,
    );
  }

  @override
  Future<SeatUnavailable> getUnavailable({
    required context,
    required String date,
    required String journeyId,
  }) {
    return seatNetworkRequest.getUnavailable(
      context: context,
      date: date,
      journeyId: journeyId,
    );
  }
}
