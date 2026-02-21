import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../base/state_controller.dart';
import '../../data/model/reponse/membership_response.dart';
import '../../data/model/reponse/membership_ticket_response.dart';
import '../../../../models/saving_point/saving_point_response.dart';
import '../../../../models/saving_point/saving_list_response.dart';
import '../../domain/uscase/member_ship_usecase.dart';
import '../uistate/member_ship_ui_state.dart';

class MemberShipController extends StateController<MemberShipUiState>
    with GetSingleTickerProviderStateMixin {
  final MemberShipUseCase memberShipUseCase;

  MemberShipController(this.memberShipUseCase);

  late final TabController tabController;

  Future<MemberShipResponse>? futureMembership;
  Future<GetTicketMemberCardResponse>? futureMembershipTicket;

  // Saving Point state
  Future<SavingPointResponse>? futureSavingPoint;
  Future<SavingListResponse>? futureSavingPointList;

  // Month selections and UI toggles
  final monthsEn = const <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final monthsKh = const <String>[
    'មករា',
    'កុម្ភៈ',
    'មិនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];

  final RxString status = ''.obs; // English month name
  final RxString statusKh = ''.obs; // Khmer month name
  final RxBool showInfo = false.obs;
  final RxBool showTicketInfo = false.obs;

  @override
  MemberShipUiState onInitUiState() => const MemberShipUiState();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    final mIndex = now.month - 1;
    status.value = monthsEn[mIndex];
    statusKh.value = monthsKh[mIndex];
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

  // Saving Point: Account summary by month/year
  Future<SavingPointResponse> loadSavingPointAccount(BuildContext context) {
    final existing = futureSavingPoint;
    if (existing != null) return existing;

    final locale = Get.locale?.toString() ?? 'en_US';
    final monthNumber =
        locale == 'en_US'
            ? (monthsEn.indexOf(status.value) + 1)
            : (monthsKh.indexOf(statusKh.value) + 1);

    final next = memberShipUseCase.getSavingPointAccount(
      context: context,
      month: monthNumber.toString(),
      year: getYear().toString(),
    );
    futureSavingPoint = next;
    return next;
  }

  Future<SavingListResponse> loadSavingPointList(BuildContext context) {
    final existing = futureSavingPointList;
    if (existing != null) return existing;

    final next = memberShipUseCase.getSavingPointList(context: context);
    futureSavingPointList = next;
    return next;
  }

  void onMonthChanged(String value, BuildContext context) {
    final locale = Get.locale?.toString() ?? 'en_US';
    if (locale == 'en_US') {
      status.value = value;
    } else {
      statusKh.value = value;
    }

    final monthNumber =
        locale == 'en_US'
            ? (monthsEn.indexOf(status.value) + 1)
            : (monthsKh.indexOf(statusKh.value) + 1);

    futureSavingPoint = memberShipUseCase.getSavingPointAccount(
      context: context,
      month: monthNumber.toString(),
      year: getYear().toString(),
    );

    // Trigger observers
    uiState.refresh();
  }

  void toggleShowInfo() {
    showInfo.value = !showInfo.value;
  }

  void toggleTicketInfo() {
    showTicketInfo.value = !showTicketInfo.value;
  }

  int getYear() => DateTime.now().year;

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
