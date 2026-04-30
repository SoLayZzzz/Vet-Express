import 'package:express_vet/base/network_data_source.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';
import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';

class TicketHistoryNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  TicketHistoryNetworkRequest(this.netWorkDataSource);

  Future<BookingListModel> fetchBookingList({required dynamic context}) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.ticketBookingList,
      body: <String, dynamic>{'page': 1, 'rowsPerPage': 100},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return BookingListModel.fromJson(json);
  }
}
