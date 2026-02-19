import '../../domain/repository/scan_qr_repository.dart';
import '../network/scan_qr_network_request.dart';

class ScanQrRepositoryImpl implements ScanQrRepository {
  final ScanQrNetworkRequest scanQrNetworkRequest;

  ScanQrRepositoryImpl(this.scanQrNetworkRequest);

  @override
  Future<Map<String, dynamic>> searchCode({
    required dynamic context,
    required String code,
  }) {
    return scanQrNetworkRequest.searchCode(context: context, code: code);
  }

  @override
  Future<Map<String, dynamic>> findGoodsTransfer({
    required dynamic context,
    required int id,
  }) {
    return scanQrNetworkRequest.findGoodsTransfer(context: context, id: id);
  }
}
