class EvTicketStationListRequest {
  final String? name;
  final String? provinceId;

  const EvTicketStationListRequest({this.name, this.provinceId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    if (provinceId != null && provinceId!.isNotEmpty) {
      json['provinceId'] = provinceId;
    }
    if (name != null && name!.isNotEmpty) {
      json['name'] = name;
    }
    return json;
  }
}

class EvPagedListRequest {
  final int page;
  final int rowsPerPage;
  final String searchText;

  const EvPagedListRequest({
    required this.page,
    required this.rowsPerPage,
    this.searchText = '',
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'page': page,
        'rowsPerPage': rowsPerPage,
        'searchText': searchText,
      };
}

class EvStationListRequest {
  final int page;
  final int rowsPerPage;
  final String? searchText;
  final int? provinceId;

  const EvStationListRequest({
    required this.page,
    required this.rowsPerPage,
    this.searchText,
    this.provinceId,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'page': page,
        'rowsPerPage': rowsPerPage,
        'searchText': searchText,
        'provinceId': provinceId,
      };
}

class EvWalletTopUpRequest {
  final double amount;
  final int paymentMethod;

  const EvWalletTopUpRequest({required this.amount, required this.paymentMethod});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'amount': amount,
        'paymentMethod': paymentMethod,
      };
}
