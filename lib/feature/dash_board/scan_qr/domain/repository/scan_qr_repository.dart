abstract class ScanQrRepository {
  Future<Map<String, dynamic>> searchCode({
    required dynamic context,
    required String code,
  });

  Future<Map<String, dynamic>> findGoodsTransfer({
    required dynamic context,
    required int id,
  });
}
