import 'package:flutter/widgets.dart';

import '../../../../../base/state_controller.dart';
import '../../domain/uscase/contact_us_usecase.dart';
import '../uiState/contact_us_ui_state.dart';

class ContactUsController extends StateController<ContactUsUiState> {
  final ContactUsUseCase useCase;

  ContactUsController(this.useCase);

  @override
  ContactUsUiState onInitUiState() => const ContactUsUiState();

  void loadContactList({required BuildContext context, int page = 1, int rowsPerPage = 100}) {
    uiState.value = state.copyWith(
      futureList: useCase.fetchContactList(
        context: context,
        page: page,
        rowsPerPage: rowsPerPage,
      ),
    );
  }
}
