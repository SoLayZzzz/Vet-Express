class ABAPayResponse {
  int? status;
  String? info;
  String? qrCode;
  String? abapayDeeplink;
  String? appStore;
  String? playStore;
  String? checkout_qr_url;

  ABAPayResponse({
    status,
    info,
    qrCode,
    abapayDeeplink,
    appStore,
    playStore,
    checkout_qr_url,
  });

  ABAPayResponse.fromJson(Map<String, dynamic> json) {
    final dynamic body = json['body'];
    final dynamic data = json['data'];
    final dynamic result = json['result'];
    final Map<String, dynamic> payload =
        body is Map<String, dynamic>
            ? body
            : data is Map<String, dynamic>
            ? data
            : result is Map<String, dynamic>
            ? result
            : json;

    status = payload['status'];
    info = payload['info'];
    qrCode = payload['qr_code'];
    abapayDeeplink = payload['abapay_deeplink'];
    appStore = payload['app_store'];
    playStore = payload['play_store'];
    checkout_qr_url = payload['checkout_qr_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['info'] = info;
    data['qr_code'] = qrCode;
    data['abapay_deeplink'] = abapayDeeplink;
    data['app_store'] = appStore;
    data['play_store'] = playStore;
    data['checkout_qr_url'] = checkout_qr_url;
    return data;
  }
}
