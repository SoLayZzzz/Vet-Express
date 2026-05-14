import 'package:express_vet/base/network_data_source.dart';


import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';
import '../model/request/destination_request.dart';
import '../model/response/destination_response.dart';

class TicketMenuNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  TicketMenuNetworkRequest(this.netWorkDataSource);

  Future<DestinationResponse> destinationsFrom(
    DestinationsFromRequest request,
  ) async {
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.ticketDestinationsFrom,
      fields: request.toFields(),
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );

    return DestinationResponse.fromJson(json);
  }

  Future<DestinationResponse> destinationsTo(
    DestinationsToRequest request,
  ) async {
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.ticketDestinationsTo,
      fields: request.toFields(),
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return DestinationResponse.fromJson(json);
  }
}
