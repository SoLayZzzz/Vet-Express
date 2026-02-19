import 'package:flutter/widgets.dart';

import '../../../../../models/travel_package/buy_travel_package_list_response.dart';
import '../../domain/repository/package_history_repository.dart';
import '../network/package_history_network_request.dart';

class PackageHistoryRepositoryImpl implements PackageHistoryRepository {
  final PackageHistoryNetworkRequest packageHistoryNetworkRequest;

  PackageHistoryRepositoryImpl(this.packageHistoryNetworkRequest);

  @override
  Future<BuyTravelPackageListResponse> fetchBuyList({
    required BuildContext context,
  }) {
    return packageHistoryNetworkRequest.fetchBuyList(context: context);
  }
}
