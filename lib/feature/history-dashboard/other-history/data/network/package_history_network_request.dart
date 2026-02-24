import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../models/travel_package/buy_travel_package_list_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';

class PackageHistoryNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  PackageHistoryNetworkRequest(this.netWorkDataSource);

  Future<BuyTravelPackageListResponse> fetchBuyList({
    required dynamic context,
  }) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.ticketTravelPackageGetPackage,
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return BuyTravelPackageListResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
