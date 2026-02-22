import 'package:flutter/widgets.dart';

import '../../../../../base/state_controller.dart';
import '../../domain/uscase/notifications_usecase.dart';
import '../uiState/notifications_ui_state.dart';

class NotificationsController extends StateController<NotificationsUiState> {
  final NotificationsUseCase useCase;

  NotificationsController(this.useCase);

  @override
  NotificationsUiState onInitUiState() => const NotificationsUiState();

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
