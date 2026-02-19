import '../../data/model/response/destination_response.dart';
import '../../data/model/request/destination_request.dart';
import '../repository/ticket_menu_repository.dart';

class TicketMenuUseCase {
  final TicketMenuRepository ticketMenuRepository;

  TicketMenuUseCase(this.ticketMenuRepository);

  Future<DestinationResponse> destinationsFrom(
    DestinationsFromRequest request,
  ) => ticketMenuRepository.destinationsFrom(request);

  Future<DestinationResponse> destinationsTo(DestinationsToRequest request) =>
      ticketMenuRepository.destinationsTo(request);
}
