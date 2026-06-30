import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../base/state_controller.dart';
import '../../domain/uscase/notifications_usecase.dart';
import '../uiState/notifications_ui_state.dart';
import '../../../../../controller/connectivity_controller.dart';

class NotificationsController extends StateController<NotificationsUiState> {
  final NotificationsUseCase useCase;

  NotificationsController(this.useCase);

  @override
  NotificationsUiState onInitUiState() => const NotificationsUiState();

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<ConnectivityController>().isConnected, (bool connected) {
      if (connected) {
        final ctx = Get.context;
        if (ctx != null) {
          loadList(context: ctx);
        }
      }
    });
  }

  void loadList({required BuildContext context, int page = 1, int rowsPerPage = 100}) {
    uiState.value = state.copyWith(
      futureList: useCase.fetchNotificationList(
        context: context,
        page: page,
        rowsPerPage: rowsPerPage,
      ),
    );
  }

  Future<void> readAll({required BuildContext context}) async {
    await useCase.readAll(context: context);
  }

  Future<void> readNotification({required BuildContext context, required String id}) async {
    await useCase.readNotification(context: context, id: id);
  }
}
