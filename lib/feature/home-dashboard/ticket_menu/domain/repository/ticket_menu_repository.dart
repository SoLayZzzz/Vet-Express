import '../../data/model/response/destination_response.dart';
import '../../data/model/request/destination_request.dart';

abstract class TicketMenuRepository {
  Future<DestinationResponse> destinationsFrom(DestinationsFromRequest request);

  Future<DestinationResponse> destinationsTo(DestinationsToRequest request);
}
