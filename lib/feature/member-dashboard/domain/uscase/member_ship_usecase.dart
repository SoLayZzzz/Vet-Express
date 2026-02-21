import '../repository/member_ship_repository.dart';
import '../../data/model/reponse/membership_response.dart';
import '../../data/model/reponse/membership_ticket_response.dart';
import '../../../../models/saving_point/saving_point_response.dart';
import '../../../../models/saving_point/saving_list_response.dart';

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

  Future<SavingPointResponse> getSavingPointAccount({
    required dynamic context,
    required String month,
    required String year,
  }) {
    return memberShipRepository.getSavingPointAccount(
      context: context,
      month: month,
      year: year,
    );
  }

  Future<SavingListResponse> getSavingPointList({required dynamic context}) {
    return memberShipRepository.getSavingPointList(context: context);
  }
}
