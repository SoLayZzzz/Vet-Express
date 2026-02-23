import 'dart:async';

import '../../../../../base/endpoint.dart';
import '../../../../../base/network_data_source.dart';
import '../../../../../models/resort/resort_response.dart';
import '../../../../../utils/contains.dart';

class ResortNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  ResortNetworkRequest(this.netWorkDataSource);

  Future<ResortResponse> fetchResortList() async {
    final json = await netWorkDataSource.postJson(
      Endpoint.ticketResortsList,
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );

    return ResortResponse.fromJson(json);
  }
}
