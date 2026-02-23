import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_contact_response.dart';

class ContactUsUiState {
  final Future<EvContactResponse>? futureList;

  const ContactUsUiState({this.futureList});

  ContactUsUiState copyWith({
    Future<EvContactResponse>? futureList,
  }) => ContactUsUiState(
    futureList: futureList ?? this.futureList,
  );
}
