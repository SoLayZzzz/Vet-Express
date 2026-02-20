import 'package:flutter/widgets.dart';

import '../../data/model/response/goods_find_response.dart';
import '../repository/scan_qr_repository.dart';

class ScanQrUseCase {
  final ScanQrRepository scanQrRepository;

  ScanQrUseCase(this.scanQrRepository);

  Future<Map<String, dynamic>> searchCode({
    required BuildContext context,
    required String code,
  }) {
    return scanQrRepository.searchCode(context: context, code: code);
  }

  Future<GoodsFindResponse> findGoodsTransfer({
    required BuildContext context,
    required int id,
  }) async {
    final json = await scanQrRepository.findGoodsTransfer(
      context: context,
      id: id,
    );
    return GoodsFindResponse.fromJson(json);
  }
}
