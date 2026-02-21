import '../../data/model/reponse/membership_response.dart';
import '../../data/model/reponse/membership_ticket_response.dart';
import '../../../../models/saving_point/saving_point_response.dart';
import '../../../../models/saving_point/saving_list_response.dart';

abstract class MemberShipRepository {
  Future<MemberShipResponse> getMemberShip({required dynamic context});

  Future<GetTicketMemberCardResponse> getMemberShipTicket({
    required dynamic context,
  });

  Future<SavingPointResponse> getSavingPointAccount({
    required dynamic context,
    required String month,
    required String year,
  });

  Future<SavingListResponse> getSavingPointList({required dynamic context});
}
