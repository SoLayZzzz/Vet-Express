import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:express_vet/base/base_url.dart';
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

    final base = BaseUrl.BASE_URL_WEB_SOCKET;
    final wsBase = base
        .replaceAll('https://', 'wss://')
        .replaceAll('http://', 'ws://');
    final cleanBase = wsBase.endsWith('/') ? wsBase.substring(0, wsBase.length - 1) : wsBase;

    _webSocket = EvChargingWebSocket(
      customUrl: cleanBase,
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

    final username = chargerUsername.value.isNotEmpty ? chargerUsername.value : 'ev01';
    final data = {
      'command_type': 'STOP_SESSION',
      'command_tpye': 'STOP_SESSION',
      'transactionId': transactionId.value,
    };
    final payload = jsonEncode(data);
    final stompSend = 'SEND\ndestination:/topic/ocpi/commands/$username\ncontent-type:application/json\n\n$payload\u0000';

    print('Sending STOP_SESSION command: $stompSend');
    _webSocket.send(stompSend);
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
