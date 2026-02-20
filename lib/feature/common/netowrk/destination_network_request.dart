import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/base/endpoint.dart';
import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/common/model/reponse/destination_from.dart';
import 'package:express_vet/feature/common/model/reponse/destination_to.dart';
import 'package:express_vet/utils/contains.dart';
import 'package:get/get.dart';

class DestinationNetworkRequest {
  final NetWorkDataSource _ticketDataSource;

  DestinationNetworkRequest({NetWorkDataSource? dataSource})
    : _ticketDataSource =
          dataSource ?? NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET);

  Future<DesFromResponse> getDesFrom(
    dynamic context, {
    String lang = '',
    String type = '',
    String searchText = '',
  }) async {
    final json = await _ticketDataSource.postFormUrlEncoded(
      Endpoint.ticketDestinationsFrom,
      fields: <String, String>{
        'lang': lang.isNotEmpty ? lang : (Get.locale?.toString() ?? 'en_US'),
        'type': type,
        'searchText': searchText,
      },
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return DesFromResponse.fromJson(json);
  }

  Future<DesToResponse> getDesTo(
    dynamic context,
    int fromId, {
    String lang = '',
    String type = '',
    String searchText = '',
  }) async {
    final json = await _ticketDataSource.postFormUrlEncoded(
      Endpoint.ticketDestinationsTo,
      fields: <String, String>{
        'fromId': fromId.toString(),
        'lang': lang.isNotEmpty ? lang : (Get.locale?.toString() ?? 'en_US'),
        'type': type,
        'searchText': searchText,
      },
      attachAuth: true,
      timeout: const Duration(seconds: Constrains.timeout30),
    );
    return DesToResponse.fromJson(json);
  }
}
