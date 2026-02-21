import '../../domain/repository/member_ship_repository.dart';
import '../network/member_ship_network_request.dart';
import '../model/reponse/membership_response.dart';
import '../model/reponse/membership_ticket_response.dart';
import '../../../../models/saving_point/saving_point_response.dart';
import '../../../../models/saving_point/saving_list_response.dart';

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

  @override
  Future<SavingPointResponse> getSavingPointAccount({
    required dynamic context,
    required String month,
    required String year,
  }) {
    return memberShipNetworkRequest.getSavingPointAccount(
      context: context,
      month: month,
      year: year,
    );
  }

  @override
  Future<SavingListResponse> getSavingPointList({required dynamic context}) {
    return memberShipNetworkRequest.getSavingPointList(context: context);
  }
}
