import '../../../../../models/travel_package/buy_travel_package_list_response.dart';

class PackageHistoryUiState {
  final Future<BuyTravelPackageListResponse>? futureBuyList;

  const PackageHistoryUiState({this.futureBuyList});

  PackageHistoryUiState copyWith({
    Future<BuyTravelPackageListResponse>? futureBuyList,
  }) => PackageHistoryUiState(
    futureBuyList: futureBuyList ?? this.futureBuyList,
  );
}
