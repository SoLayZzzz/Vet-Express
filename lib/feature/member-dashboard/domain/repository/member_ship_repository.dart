import '../../data/model/reponse/membership_response.dart';
import '../../data/model/reponse/membership_ticket_response.dart';

abstract class MemberShipRepository {
  Future<MemberShipResponse> getMemberShip({required dynamic context});

  Future<GetTicketMemberCardResponse> getMemberShipTicket({
    required dynamic context,
  });
}
