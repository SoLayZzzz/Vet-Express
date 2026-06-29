import 'dart:async';
import 'package:get/get.dart';
import '../../data/network/ev_charging_websocket.dart';
import 'ev_charger_controller.dart';

class EvDetailChargingController extends GetxController {
  final RxInt percent = 1.obs;
  final RxString estimatedTime = '30 mins'.obs;
  final RxString timeElapsed = '14 mins'.obs;
  final RxString current = '60 A'.obs;
  final RxString voltage = '500 V'.obs;
  final RxString energy = '6 / 15 kWh'.obs;
  final RxString estimatedCost = '៛2,000.00'.obs;
  final RxString transactionId = ''.obs;
  final RxString chargerUsername = ''.obs;

  late final EvChargingWebSocket _webSocket;
  StreamSubscription<EvChargingData>? _wsSubscription;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      transactionId.value = args['transactionId'] ?? '';
      chargerUsername.value = args['chargerUsername'] ?? '';
    }

    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (percent.value >= 100) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      percent.value = (percent.value + 1).clamp(0, 100);
    });

    _webSocket = EvChargingWebSocket(
      transactionId: transactionId.value,
      chargerUsername: chargerUsername.value,
    );
    _wsSubscription = _webSocket.stream.listen((data) {
      _timer?.cancel();
      _timer = null;

      percent.value = data.percent;
      estimatedTime.value = data.estimatedTime;
      timeElapsed.value = data.timeElapsed;
      current.value = data.current;
      voltage.value = data.voltage;
      energy.value = data.energy;
      estimatedCost.value = data.estimatedCost;
    }, onError: (error) {
      Get.log('WebSocket error in controller: $error');
    });
  }

  void stopCharging() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onClose() {
    _timer?.cancel();
    _wsSubscription?.cancel();
    _webSocket.close();
    if (Get.isRegistered<EvChargerController>()) {
      Get.find<EvChargerController>().fetchChargingStatus();
    }
    super.onClose();
  }
}
