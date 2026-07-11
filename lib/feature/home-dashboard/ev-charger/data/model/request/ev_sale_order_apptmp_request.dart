class EvSaleOrderApptmpRequest {
  final String chargerUsername;
  final int plugId;
  final int paymentMethod;
  final int discountPercentage;
  final int discount;
  final int voucherId;
  final int membershipRedeemId;
  final int totalKwh;
  final double totalPrice;
  final double grandTotalPrice;

  EvSaleOrderApptmpRequest({
    required this.chargerUsername,
    required this.plugId,
    required this.paymentMethod,
    required this.discountPercentage,
    required this.discount,
    required this.voucherId,
    required this.membershipRedeemId,
    required this.totalKwh,
    required this.totalPrice,
    required this.grandTotalPrice,
  });

  // Converts the Object into a Map
  Map<String, dynamic> toJson() {
    return {
      'chargerUsername': chargerUsername,
      'plugId': plugId,
      'paymentMethod': paymentMethod,
      'discountPercentage': discountPercentage,
      'discount': discount,
      'voucherId': voucherId,
      'membershipRedeemId': membershipRedeemId,
      'totalKwh': totalKwh,
      'totalPrice': totalPrice,
      'grandTotalPrice': grandTotalPrice,
    };
  }
}