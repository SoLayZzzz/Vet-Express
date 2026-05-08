import 'package:express_vet/base/network_data_source.dart';
import 'package:flutter/material.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';
import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';
import '../model/response/ticket_detail_response.dart';

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
    debugPrint("===> Ticket history response: $json");
    return BookingListModel.fromJson(json);
  }

  Future<TicketDetailScreenReponse> fetchTicketDetail({
    required BuildContext context,
    required int id,
  }) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.ticketBookingFind(id.toString()),
      body: <String, dynamic>{'id': id},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    debugPrint("===> Ticket detail response: $json");
    return TicketDetailScreenReponse.fromJson(json);
  }
}
