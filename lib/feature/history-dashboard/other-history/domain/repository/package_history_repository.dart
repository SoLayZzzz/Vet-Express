import 'package:flutter/widgets.dart';

import '../../../../../models/travel_package/buy_travel_package_list_response.dart';

abstract class PackageHistoryRepository {
  Future<BuyTravelPackageListResponse> fetchBuyList({
    required BuildContext context,
  });
}
