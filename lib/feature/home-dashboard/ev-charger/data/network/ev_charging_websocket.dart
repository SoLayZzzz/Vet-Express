import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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

      final isStomp = url.contains('/OCPI/ws');
      if (isStomp) {
        final stompConnect = 'CONNECT\naccept-version:1.1,1.2\nheart-beat:10000,10000\n\n\u0000';
        final username = (chargerUsername != null && chargerUsername!.isNotEmpty) ? chargerUsername : 'ev01';
        final stompSubscribe = 'SUBSCRIBE\nid:sub-0\ndestination:/topic/ocpi/commands/$username\n\n\u0000';

        debugPrint('Sending STOMP CONNECT to EV charging WebSocket');
        _channel!.sink.add(stompConnect);

        Future.delayed(const Duration(milliseconds: 250), () {
          if (_channel != null && _shouldReconnect) {
            debugPrint('Sending STOMP SUBSCRIBE to destination: /topic/ocpi/commands/$username');
            _channel!.sink.add(stompSubscribe);

            if (transactionId != null && transactionId!.isNotEmpty) {
              final data = {
                'command_type': 'START_SESSION',
                'command_tpye': 'START_SESSION',
                'transactionId': transactionId,
              };
              final payload = jsonEncode(data);
              final stompSend = 'SEND\ndestination:/topic/ocpi/commands/$username\ncontent-type:application/json\n\n$payload\u0000';

              Future.delayed(const Duration(milliseconds: 200), () {
                if (_channel != null && _shouldReconnect) {
                  debugPrint('Sending STOMP START_SESSION command: $stompSend');
                  _channel!.sink.add(stompSend);
                }
              });
            }
          }
        });
      }

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
      String rawJson = message.toString().trim();
      if (rawJson.isEmpty) return;

      if (rawJson.startsWith('MESSAGE')) {
        final parts = rawJson.split('\n\n');
        if (parts.length > 1) {
          rawJson = parts.sublist(1).join('\n\n');
        } else {
          final doubleReturnParts = rawJson.split('\r\n\r\n');
          if (doubleReturnParts.length > 1) {
            rawJson = doubleReturnParts.sublist(1).join('\r\n\r\n');
          }
        }
        if (rawJson.endsWith('\u0000')) {
          rawJson = rawJson.substring(0, rawJson.length - 1);
        } else if (rawJson.endsWith('\x00')) {
          rawJson = rawJson.substring(0, rawJson.length - 1);
        }
        rawJson = rawJson.trim();
      } else if (!rawJson.startsWith('{') && !rawJson.startsWith('[')) {
        // Ignore other STOMP control frames like CONNECTED, RECEIPT, or HEARTBEATS
        return;
      }

      final dataMap = jsonDecode(rawJson);
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

  void send(dynamic message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
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

  static final NumberFormat _costFormatter = NumberFormat('#,##0.00', 'en_US');

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
    final commandType = json['command_type'] as String?;

    if (commandType == 'MeterValues') {
      final soc = (json['soc'] as num?)?.toInt() ?? 0;
      final duration = (json['duration'] as num?)?.toInt() ?? 0;
      final remaining = (json['remaining'] as num?)?.toInt() ?? 0;
      final w = (json['w'] as num?)?.toDouble() ?? 0.0;
      final kwh = (json['kwh'] as num?)?.toDouble() ?? 0.0;
      final rate = (json['rate'] as num?)?.toDouble() ?? 0.0;
      final cost = kwh * rate;

      return EvChargingData(
        percent: soc,
        estimatedTime: _formatDuration(remaining),
        timeElapsed: _formatDuration(duration),
        current: w >= 1000 ? '${(w / 1000).toStringAsFixed(2)} kW' : '${w.toStringAsFixed(0)} W',
        voltage: json['voltage'] != null ? '${json['voltage']} V' : '0 V',
        energy: '${kwh.toStringAsFixed(2)} kWh',
        estimatedCost: '៛${_costFormatter.format(cost)}',
        status: 'charging',
      );
    }

    return EvChargingData(
      percent: json['percent'] as int? ?? 0,
      estimatedTime: json['estimatedTime'] as String? ?? '',
      timeElapsed: json['timeElapsed'] as String? ?? '',
      current: json['current'] as String? ?? '',
      voltage: json['voltage'] as String? ?? '',
      energy: json['energy'] as String? ?? '',
      estimatedCost: json['estimatedCost'] as String? ?? '',
      status: json['status'] as String? ?? 'charging',
    );
  }

  static String _formatDuration(int seconds) {
    if (seconds <= 0) return '0 min';
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${seconds ~/ 60} min';
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    return '$hours hr ${mins}min';
  }
}
