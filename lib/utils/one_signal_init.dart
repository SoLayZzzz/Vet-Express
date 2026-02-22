import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:express_vet/feature/home-dashboard/notifications/presentation/screen/notification_screen.dart';
import 'navigate.dart';

Future<void> initOneSignalPlatformState() async {
  // * Enable verbose OneSignal logging to debug issues if needed.
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);

  // * Init OneSignal App ID
  OneSignal.initialize("ad750737-ae96-4a44-8a5f-7ca43914ebe2");

  // * Request Notification Permission
  OneSignal.Notifications.requestPermission(true);

  // * Init Onesignal Notification Opened Handler
  _initNotificationOpenedHandler();
}

void _initNotificationOpenedHandler() {
  // * Init Notification Opened Handler
  OneSignal.Notifications.addClickListener((openedResult) async {
    Navigator.push(
      getCurrentContext()!,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  });
}

///testing one signal
/* IconButton(
            onPressed: () {
              OneSignalService.sendPushNotification(
                playerIds: [
                  Platform.isAndroid
                      ? '166d3b35-fc93-43a0-bf5a-3123ee373846'
                      : 'f17c4d94-5255-4acd-8a12-2db56f8614bc',
                ],
                title: Platform.isAndroid ? 'From Android' : 'From iOS',
                message: 'Notification push from Mobile app',
                imageUrl:
                    'https://qacltom.udaya-tech.com/eventMgtWebAPi/upload/ceae7020-16f6-4ce0-8847-8a6250defdc0.jpg',
              );
            },
            icon: Icon(Icons.abc),
          ),*/

/*
class OneSignalService {
  static Future<void> sendPushNotification({
    required List<String> playerIds,
    required String title,
    required String message,
    required String imageUrl,
  }) async {
    final url = Uri.parse('https://onesignal.com/api/v1/notifications');

    final payload = {
      'app_id': 'ad750737-ae96-4a44-8a5f-7ca43914ebe2',
      'include_player_ids': playerIds,
      'headings': {'en': title},
      'contents': {'en': message},
      'big_picture': imageUrl, // For Android
      'ios_attachments': {
        'id1': imageUrl, // For iOS
      },
    };

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic os_v2_app_vv2qon5oszfejcs7pssdsfhl4jxhmjixjvdeaxfurg4qtuohjz7i7r5skscaamqdggnexrvz2p3nezypxzwuracwe6443ydaiitz7ka',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    log('Notification Response', error: Map.from(jsonDecode(response.body)));

    if (response.statusCode == 200) {
      print('✅ Notification sent successfully!');
    } else {
      print('❌ Failed to send notification: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
  // * Fetch Date Next Week
  Future<List<DateTime>> fetchDateNextWeek({required int page, required int rowPerPage}) async {
    // * Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(rowPerPage, (index) {
      final offset = (page - 1) * rowPerPage + index;
      return DateTime.now().add(Duration(days: offset));
    });
  }
}*/
