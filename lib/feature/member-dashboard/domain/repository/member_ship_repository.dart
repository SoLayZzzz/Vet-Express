import '../../../../models/membership/membership_response.dart';
import '../../../../models/membership/membership_ticket_response.dart';

abstract class MemberShipRepository {
  Future<MemberShipResponse> getMemberShip({required dynamic context});

  Future<GetTicketMemberCardResponse> getMemberShipTicket({
    required dynamic context,
  });
}
