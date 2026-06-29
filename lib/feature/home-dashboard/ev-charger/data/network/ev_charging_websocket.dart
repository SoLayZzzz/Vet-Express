import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../../base/base_url.dart';
import '../../../../../utils/app_pref.dart';

class EvChargingWebSocket {
  final String? customUrl;
  final String? transactionId;
  final String? chargerUsername;
  WebSocketChannel? _channel;
  StreamController<EvChargingData>? _streamController;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  Timer? _reconnectTimer;

  EvChargingWebSocket({this.customUrl, this.transactionId, this.chargerUsername});

  Stream<EvChargingData> get stream {
    _streamController ??= StreamController<EvChargingData>.broadcast(
      onListen: _connect,
      onCancel: _disconnect,
    );
    return _streamController!.stream;
  }

  String get _wsUrl {
    if (customUrl != null && customUrl!.isNotEmpty) {
      return customUrl!;
    }
    final base = BaseUrl.BASE_URL_WEB_SOCKET;
    final String cleanWsBase;
    if (base.contains('/topic/')) {
      final beforeTopic = base.split('/topic/')[0];
      cleanWsBase = beforeTopic.contains('?') ? beforeTopic.split('?')[0] : beforeTopic;
    } else if (base.contains('?')) {
      cleanWsBase = base.split('?')[0];
    } else {
      cleanWsBase = base;
    }

    final wsBase = cleanWsBase
        .replaceAll('https://', 'wss://')
        .replaceAll('http://', 'ws://');
    final cleanBase = wsBase.endsWith('/') ? wsBase.substring(0, wsBase.length - 1) : wsBase;

    final username = (chargerUsername != null && chargerUsername!.isNotEmpty)
        ? chargerUsername
        : 'udaya';

    return '$cleanBase?username=$username/profile/charging-status/ws?transactionId=${transactionId ?? ""}';
  }

  void _connect() {
    if (_isConnecting) return;
    _isConnecting = true;
    _shouldReconnect = true;

    final url = _wsUrl;
    debugPrint('Connecting to EV charging WebSocket: $url');

    try {
      final uri = Uri.parse(url);
      final token = AppPref.getToken();

      _channel = WebSocketChannel.connect(
        uri,
        protocols: token != null ? ['Authorization', token] : null,
      );

      _channel!.stream.listen(
        (message) {
          _isConnecting = false;
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('EV charging WebSocket error: $error');
          _isConnecting = false;
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('EV charging WebSocket connection closed.');
          _isConnecting = false;
          if (_shouldReconnect) {
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      debugPrint('EV charging WebSocket connection exception: $e');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic message) {
    debugPrint('EV charging WebSocket received: $message');
    try {
      final dataMap = jsonDecode(message);
      if (dataMap is Map<String, dynamic>) {
        final chargingData = EvChargingData.fromJson(dataMap);
        _streamController?.add(chargingData);
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
        _connect();
      }
    });
  }

  void _disconnect() {
    debugPrint('Disconnecting EV charging WebSocket...');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
  }

  void close() {
    _disconnect();
    _streamController?.close();
    _streamController = null;
  }
}

class EvChargingData {
  final int percent;
  final String estimatedTime;
  final String timeElapsed;
  final String current;
  final String voltage;
  final String energy;
  final String estimatedCost;
  final String status; // 'charging', 'stopped', 'completed'

  EvChargingData({
    required this.percent,
    required this.estimatedTime,
    required this.timeElapsed,
    required this.current,
    required this.voltage,
    required this.energy,
    required this.estimatedCost,
    required this.status,
  });

  factory EvChargingData.fromJson(Map<String, dynamic> json) {
    return EvChargingData(
      percent: json['percent'] as int? ?? 0,
      estimatedTime: json['estimatedTime'] as String? ?? '30 mins',
      timeElapsed: json['timeElapsed'] as String? ?? '14 mins',
      current: json['current'] as String? ?? '60 A',
      voltage: json['voltage'] as String? ?? '500 V',
      energy: json['energy'] as String? ?? '6 / 15 kWh',
      estimatedCost: json['estimatedCost'] as String? ?? '៛2,000.00',
      status: json['status'] as String? ?? 'charging',
    );
  }
}
