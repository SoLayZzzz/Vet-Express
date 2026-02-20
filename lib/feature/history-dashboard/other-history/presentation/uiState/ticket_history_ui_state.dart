import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';

class TicketHistoryUiState {
  final Future<BookingListModel>? futureListBooking;

  const TicketHistoryUiState({this.futureListBooking});

  TicketHistoryUiState copyWith({
    Future<BookingListModel>? futureListBooking,
  }) => TicketHistoryUiState(
    futureListBooking: futureListBooking ?? this.futureListBooking,
  );
}
