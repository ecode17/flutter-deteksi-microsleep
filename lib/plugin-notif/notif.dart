import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationWidget {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future init({bool scheduled = false}) async {
    var initAndroidSetting =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // var ios =
    final setting = InitializationSettings(android: initAndroidSetting);
    await _notification.initialize(setting);
  }

  static Future showNotification({
    var id = 0,
    var title,
    var body,
    var payload,
  }) async =>
      _notification.show(id, title, body, await notificationDetail());
  static notificationDetail() async {
    return NotificationDetails(
      android: AndroidNotificationDetails('detection123', 'Detection',
          importance: Importance.max),
    );
  }
}
