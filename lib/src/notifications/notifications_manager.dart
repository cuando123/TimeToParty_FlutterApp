import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../main.dart';
import '../app_lifecycle/translated_text.dart';
import '../in_app_purchase/services/firebase_service.dart';

class NotificationsManager {
  BuildContext context;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final FirebaseService _firebaseService;

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  NotificationsManager(this.context, this._firebaseService) {
    tz.initializeTimeZones();
    initializeNotifications();
  }

  Future<void> onSelectNotification(NotificationResponse? response) async {
    //TO_DO do przetestowania
    print('payload $response');
    if (response?.payload != null && response!.payload!.isNotEmpty) {
      userInfo.lastNotificationClicked = DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now());
      await _firebaseService.updateUserInformations(userInfo.userID, 'lastNotificationClicked', userInfo.lastNotificationClicked);
    }
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onSelectNotification);
    //(details) =>
    //         onSelectNotification(details.payload as NotificationResponse?));
  }

  Future<void> scheduleWeeklyNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'weekly_notification_channel', 'Weekly Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        getTranslatedString(context, 'weekly_notification_up'),
        getTranslatedString(context, 'weekly_notification_down'),
        _nextInstanceOfMonday1900(),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  tz.TZDateTime _nextInstanceOfMonday1900() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 0, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 7));
    }
    return scheduledDate;
  }
  Future<void> showNotificationNow(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'immediate_notification_channel', // Może być potrzebne utworzenie nowego kanału dla tego typu powiadomień
        'Immediate Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true);

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Unikalne ID notyfikacji
      title,
      body,
      platformChannelSpecifics,
      payload: 'UniquePayloadValue', // Tutaj dodajesz payload
    );
  }

}