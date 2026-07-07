import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;
  Timer? _timer;
  bool _shouldReconnect = true;
  Timer? _reconnectTimer;
  Completer<bool>? _stopCompleter;

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

    _connectWebSocket();
  }

  void _connectWebSocket() {
    final wsUrl = BaseUrl.BASE_URL_WEB_SOCKET;
    final username = chargerUsername.value.isNotEmpty ? chargerUsername.value : 'ev01';

    debugPrint('Connecting to EV charging WebSocket: $wsUrl');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      final stompSend =
          'SEND\ndestination:/topic/ocpi/commands/$username\ncontent-type:application/json\n\n\u0000';

      debugPrint('destination:/topic/ocpi/commands/$username');
      debugPrint('content-type:application/json');
      _channel!.sink.add(stompSend);

      _wsSubscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('EV charging WebSocket error: $error');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('EV charging WebSocket connection closed.');
          if (_shouldReconnect) {
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      debugPrint('EV charging WebSocket connection exception: $e');
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    debugPrint('EV charging WebSocket received: $message');
    try {
      String rawJson = message.toString().trim();
      if (rawJson.isEmpty) return;

      if (rawJson.startsWith('MESSAGE')) {
        final parts = rawJson.split('\n\n');
        if (parts.length > 1) {
          rawJson = parts.sublist(1).join('\n\n');
        }
        if (rawJson.endsWith('\u0000')) {
          rawJson = rawJson.substring(0, rawJson.length - 1);
        }
        rawJson = rawJson.trim();
      } else if (!rawJson.startsWith('{') && !rawJson.startsWith('[')) {
        return;
      }

      final dataMap = jsonDecode(rawJson);
      if (dataMap is Map<String, dynamic>) {
        final chargingData = EvChargingData.fromJson(dataMap);
        _timer?.cancel();
        _timer = null;

        percent.value = chargingData.percent;
        estimatedTime.value = chargingData.estimatedTime;
        timeElapsed.value = chargingData.timeElapsed;
        current.value = chargingData.current;
        voltage.value = chargingData.voltage;
        energy.value = chargingData.energy;
        estimatedCost.value = chargingData.estimatedCost;

        if (_stopCompleter != null && !_stopCompleter!.isCompleted) {
          _stopCompleter!.complete(true);
        }
      }
    } catch (e) {
      debugPrint('Error parsing EV charging WebSocket message: $e');
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_shouldReconnect) {
        _connectWebSocket();
      }
    });
  }

  Future<bool> stopCharging() {
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

    debugPrint('Sending STOP_SESSION command: $stompSend');
    _channel?.sink.add(stompSend);

    _stopCompleter = Completer<bool>();
    return _stopCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => true,
    );
  }

  @override
  void onClose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _timer?.cancel();
    _wsSubscription?.cancel();
    _channel?.sink.close();
    if (Get.isRegistered<EvChargerController>()) {
      Get.find<EvChargerController>().fetchChargingStatus();
    }
    super.onClose();
  }
}
