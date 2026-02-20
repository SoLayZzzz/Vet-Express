import '../../domain/repository/member_ship_repository.dart';
import '../network/member_ship_network_request.dart';
import '../model/reponse/membership_response.dart';
import '../model/reponse/membership_ticket_response.dart';

class MemberShipRepositoryImpl implements MemberShipRepository {
  final MemberShipNetworkRequest memberShipNetworkRequest;

  MemberShipRepositoryImpl(this.memberShipNetworkRequest);

  @override
  Future<MemberShipResponse> getMemberShip({required dynamic context}) {
    return memberShipNetworkRequest.getMemberShip(context: context);
  }

  @override
  Future<GetTicketMemberCardResponse> getMemberShipTicket({
    required dynamic context,
  }) {
    return memberShipNetworkRequest.getMemberShipTicket(context: context);
  }
}
