import 'package:get/get.dart';

import '../../../../../base/network_data_source.dart';
import '../../data/network/scan_qr_network_request.dart';
import '../../data/repositoryImpl/scan_qr_repository_impl.dart';
import '../../domain/repository/scan_qr_repository.dart';
import '../../domain/uscase/scan_qr_usecase.dart';
import '../controller/scan_qr_controller.dart';

class ScanQrBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ScanQrNetworkRequest>()) {
      Get.lazyPut(
        () => ScanQrNetworkRequest(Get.find<NetworkDataSource>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScanQrRepository>()) {
      Get.lazyPut<ScanQrRepository>(
        () => ScanQrRepositoryImpl(Get.find<ScanQrNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScanQrUseCase>()) {
      Get.lazyPut(
        () => ScanQrUseCase(Get.find<ScanQrRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScanQrController>()) {
      Get.lazyPut(
        () => ScanQrController(Get.find<ScanQrUseCase>()),
        fenix: true,
      );
    }
  }
}
