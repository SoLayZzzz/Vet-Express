class EvCalculateRequest {
  final String chargerUserName;
  final int voucherId;
  final int? redeemId;
  final String? amountKh;

  EvCalculateRequest({
    required this.chargerUserName,
    required this.voucherId,
    this.redeemId,
    this.amountKh,
  });

  Map<String, dynamic> toJson() {
    return {
      'chargerUserName': chargerUserName,
      'voucherId': voucherId,
      if (redeemId != null) 'redeemId': redeemId,
      if (amountKh != null) 'amountKh': amountKh,
    };
  }

  Map<String, String> toFormFields() {
    return <String, String>{
      'chargerUserName': chargerUserName,
      'voucherId': voucherId.toString(),
      if (redeemId != null) 'redeemId': redeemId.toString(),
      if (amountKh != null) 'amountKh': amountKh!,
    };
  }
}
