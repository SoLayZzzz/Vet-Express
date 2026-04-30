import 'package:express_vet/base/network_data_source.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../models/travel_package/buy_travel_package_list_response.dart';
import '../../../../../utils/contains.dart';

class PackageHistoryNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  PackageHistoryNetworkRequest(this.netWorkDataSource);

  Future<BuyTravelPackageListResponse> fetchBuyList({
    required dynamic context,
  }) async {
    final json = await netWorkDataSource.postJson(
      Endpoint.ticketTravelPackageGetPackage,
      body: <String, dynamic>{},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return BuyTravelPackageListResponse.fromJson(json);
  }
}
