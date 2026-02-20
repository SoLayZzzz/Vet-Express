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
    status = json['status'];
    info = json['info'];
    qrCode = json['qr_code'];
    abapayDeeplink = json['abapay_deeplink'];
    appStore = json['app_store'];
    playStore = json['play_store'];
    checkout_qr_url = json['checkout_qr_url'];
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
