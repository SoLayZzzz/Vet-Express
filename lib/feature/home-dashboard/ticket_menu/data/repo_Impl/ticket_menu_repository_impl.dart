import '../../domain/repository/ticket_menu_repository.dart';
import '../model/request/destination_request.dart';
import '../model/response/destination_response.dart';
import '../network/ticket_menu_network_request.dart';

class TicketMenuRepositoryImpl implements TicketMenuRepository {
  final TicketMenuNetworkRequest ticketMenuNetworkRequest;

  TicketMenuRepositoryImpl(this.ticketMenuNetworkRequest);

  @override
  Future<DestinationResponse> destinationsFrom(
    DestinationsFromRequest request,
  ) => ticketMenuNetworkRequest.destinationsFrom(request);

  @override
  Future<DestinationResponse> destinationsTo(DestinationsToRequest request) =>
      ticketMenuNetworkRequest.destinationsTo(request);
}
