import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../base/state_controller.dart';
import '../../../../models/membership/membership_response.dart';
import '../../../../models/membership/membership_ticket_response.dart';
import '../../domain/uscase/member_ship_usecase.dart';
import '../uistate/member_ship_ui_state.dart';

class MemberShipController extends StateController<MemberShipUiState>
    with GetSingleTickerProviderStateMixin {
  final MemberShipUseCase memberShipUseCase;

  MemberShipController(this.memberShipUseCase);

  late final TabController tabController;

  Future<MemberShipResponse>? futureMembership;
  Future<GetTicketMemberCardResponse>? futureMembershipTicket;

  @override
  MemberShipUiState onInitUiState() => const MemberShipUiState();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<GetTicketMemberCardResponse> loadMemberShipTicket(
    BuildContext context,
  ) {
    final existing = futureMembershipTicket;
    if (existing != null) return existing;

    final next = memberShipUseCase.getMemberShipTicket(context: context);
    futureMembershipTicket = next;
    return next;
  }

  Future<MemberShipResponse> loadMemberShip(BuildContext context) {
    final existing = futureMembership;
    if (existing != null) return existing;

    final next = memberShipUseCase.getMemberShip(context: context);
    futureMembership = next;
    return next;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
