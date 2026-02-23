class GoodsTransferAddRequestBody {
  final String itemName;
  final String lats;
  final String longs;
  final String qtyType;
  final String senderAddr;
  final String serviceType;
  final String telephone;
  final String? filePath;

  const GoodsTransferAddRequestBody({
    required this.itemName,
    required this.lats,
    required this.longs,
    required this.qtyType,
    required this.senderAddr,
    required this.serviceType,
    required this.telephone,
    this.filePath,
  });

  Map<String, String> toFormFields() => <String, String>{
    'itemName': itemName,
    'lats': lats,
    'longs': longs,
    'qtyType': qtyType,
    'senderAddr': senderAddr,
    'serviceType': serviceType,
    'telephone': telephone,
  };
}
