import '../repository/member_ship_repository.dart';
import '../../data/model/reponse/membership_response.dart';
import '../../data/model/reponse/membership_ticket_response.dart';

class MemberShipUseCase {
  final MemberShipRepository memberShipRepository;

  MemberShipUseCase(this.memberShipRepository);

  Future<MemberShipResponse> getMemberShip({required dynamic context}) {
    return memberShipRepository.getMemberShip(context: context);
  }

  Future<GetTicketMemberCardResponse> getMemberShipTicket({
    required dynamic context,
  }) {
    return memberShipRepository.getMemberShipTicket(context: context);
  }
}
