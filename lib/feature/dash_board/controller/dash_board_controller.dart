import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/feature/dash_board/presentation/uistate/dash_board_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:express_vet/feature/location-dashboard/presentation/screen/location_screen.dart';
import '../../home-dashboard/self_service/presentation/screen/self_service_screen.dart';
import '../../member-dashboard/presentation/screen/member_ship_screen.dart';
import '../../history-dashboard/main-history/tracking_screen.dart';
import '../../home-dashboard/menu/presentation/screen/menu_screen.dart';
import '../scan_qr/presentation/screen/scan_qr_screen.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/contains.dart';

class DashBoardController extends StateController<DashBoardState> {
  @override
  DashBoardState onInitUiState() => const DashBoardState();

  final List<Widget> pages = const [
    MenuScreen(),
    TrackingScreen(),
    ScanQrScreen(scanFrom: 0),
    MemberShipScreen(),
  ];

  final LocationScreen locationScreen = LocationScreen();

  void onItemTapped(int index) {
    uiState.value = state.copyWith(selectedIndex: index);
  }

  void setSelectedIndex(int index) {
    uiState.value = state.copyWith(selectedIndex: index);
  }

  Widget get selectedPage {
    if (state.selectedIndex == 4) return locationScreen;
    return pages[state.selectedIndex];
  }

  void handleInitialNavigation({required int from}) {
    if (state.navigated) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.navigated) return;

      if (from == 1) {
        uiState.value = state.copyWith(navigated: true);
        Get.to(
          SelfServiceScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: Constrains.duration),
        );
      } else if (from == 2) {
        uiState.value = state.copyWith(navigated: true);
        Get.toNamed(AppRoutes.ticketHistory);
      } else if (from == 5) {
        uiState.value = state.copyWith(navigated: true);
        Get.toNamed(AppRoutes.packageHistory);
      }
    });
  }
}
