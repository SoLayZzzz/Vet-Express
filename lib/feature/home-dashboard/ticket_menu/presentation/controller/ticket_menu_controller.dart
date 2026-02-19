import '../../../../base/state_controller.dart';
import '../../../../utils/app_pref.dart';
import '../../../../utils/contains.dart';
import '../../data/model/request/destination_request.dart';
import '../../data/model/response/destination_response.dart';
import '../../domain/uscase/ticket_menu_usecase.dart';
import '../uiState/ticket_menu_ui_state.dart';

class TicketMenuController extends StateController<TicketMenuUiState> {
  final TicketMenuUseCase ticketMenuUseCase;

  TicketMenuController(this.ticketMenuUseCase);

  @override
  TicketMenuUiState onInitUiState() => const TicketMenuUiState();

  @override
  void onInit() {
    super.onInit();
    _loadLanguageFromPref();
  }

  void _loadLanguageFromPref() {
    final languagePref = AppPref.getLanguage();
    if (languagePref == Constrains.ENGLISH) {
      uiState.value = state.copyWith(language: 'en');
    } else if (languagePref == Constrains.CHINESE) {
      uiState.value = state.copyWith(language: 'cn');
    } else {
      uiState.value = state.copyWith(language: 'kh');
    }
  }

  Future<DestinationResponse> destinationsFrom({
    required String type,
    String searchText = '',
  }) {
    return ticketMenuUseCase.destinationsFrom(
      DestinationsFromRequest(
        lang: state.language,
        type: type,
        searchText: searchText,
      ),
    );
  }

  Future<DestinationResponse> destinationsTo({
    required String fromId,
    required String type,
    String searchText = '',
  }) {
    return ticketMenuUseCase.destinationsTo(
      DestinationsToRequest(
        fromId: fromId,
        lang: state.language,
        type: type,
        searchText: searchText,
      ),
    );
  }
}
