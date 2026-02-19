import 'package:flutter/widgets.dart';

import '../../../../../models/travel_package/buy_travel_package_list_response.dart';
import '../repository/package_history_repository.dart';

class PackageHistoryUseCase {
  final PackageHistoryRepository packageHistoryRepository;

  PackageHistoryUseCase(this.packageHistoryRepository);

  Future<BuyTravelPackageListResponse> fetchBuyList({
    required BuildContext context,
  }) {
    return packageHistoryRepository.fetchBuyList(context: context);
  }
}
