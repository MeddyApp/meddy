import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

const appGuid = 'ce5a66ca-fd7c-4557-a9d2-038d946be413';
const channelId = 'meddy_reminder_channel_id';
const channelName = 'Medicine Reminder Channel';
const channelDescription = 'Channel for Medicine reminders';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<NotificationAppLaunchDetails?> initAsyncNotifications() async {
  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const initializationSettingsAndroid = AndroidInitializationSettings(
    'app_icon',
  );
  final initializationSettingsDarwin = DarwinInitializationSettings();
  final initializationSettingsLinux = LinuxInitializationSettings(
    defaultActionName: 'Open notification',
  );
  final initializationSettingsWindows = WindowsInitializationSettings(
    appName: 'Flutter Local Notifications Example',
    appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
    guid: appGuid,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
    windows: initializationSettingsWindows,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  return notificationAppLaunchDetails;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  print("Notification response received");
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

Future<void> scheduleNotification() async {
  final now = tz.TZDateTime.now(tz.local);
  final when = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    now.hour,
    now.minute,
  ).add(const Duration(minutes: 1));

  print("Scheduling notification for $when");

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // FIXME: What is this ID?
    'daily scheduled notification title',
    'daily scheduled notification body',
    when,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'daily notification description',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'id_1',
            'Action 1',
            icon: DrawableResourceAndroidBitmap('app_icon'),
            contextual: true,
          ),
          AndroidNotificationAction(
            'id_2',
            'Action 2',
            titleColor: Color.fromARGB(255, 255, 0, 0),
            icon: DrawableResourceAndroidBitmap('app_icon'),
            showsUserInterface: true,
          ),
        ],
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.alarmClock,
    matchDateTimeComponents: DateTimeComponents.time,
  );

  print("Created zonedSchedule notification");
}

Future<void> configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

AndroidFlutterLocalNotificationsPlugin androidNotificationPlugin() {
  if (!Platform.isAndroid) {
    throw Exception('Error: Not running on Android');
  }

  var plugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (plugin == null) {
    throw Exception('Error: Could not get Android notification implementation');
  }

  return plugin;
}

Future<bool?> isAndroidPermissionGranted() async {
  if (Platform.isAndroid) {
    var canScheduleExact = await androidNotificationPlugin()
        .canScheduleExactNotifications();
    var areNotificationsEnabled = await androidNotificationPlugin()
        .areNotificationsEnabled();

    return canScheduleExact == true && areNotificationsEnabled == true;
  }

  return null;
}

Future<bool?> requestPermissions() async {
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  } else if (Platform.isAndroid) {
    var canScheduleExact = await androidNotificationPlugin()
        .requestExactAlarmsPermission();
    var areNotificationsEnabled = await androidNotificationPlugin()
        .requestNotificationsPermission();

    return canScheduleExact == true && areNotificationsEnabled == true;
  }

  return null;
}

/*

For bypassing the DnD setup - requestNotificationPolicyAccess


*/
