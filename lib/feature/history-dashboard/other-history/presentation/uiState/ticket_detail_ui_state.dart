import '../../data/model/response/ticket_detail_response.dart';

class TicketDetailUiState {
  final Future<TicketDetailScreenReponse>? futureTicketDetail;

  const TicketDetailUiState({this.futureTicketDetail});

  TicketDetailUiState copyWith({
    Future<TicketDetailScreenReponse>? futureTicketDetail,
  }) => TicketDetailUiState(
    futureTicketDetail: futureTicketDetail ?? this.futureTicketDetail,
  );
}
