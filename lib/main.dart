import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/db/sql_lite.dart';
import 'package:merrymakin/commons/notification/event_notification_scheduler.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:sqflite/sqflite.dart';
import 'package:merrymakin/commons/utils/platform_web.dart'
    if (dart.library.io) 'package:merrymakin/commons/utils/platform_stub.dart'
    as platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  platform.setUrlStrategyForPlatform();
  if (kIsWeb) {
    AppFactory.forFirstTimeWeb();
  } else {
    SQLiteDBHelper dbHelper = SQLiteDBHelper.instance;
    Database database = await dbHelper.database;
    AppFactory.forFirstTimeMobile(database);

    final scheduler = AppFactory().notificationScheduler;
    if (scheduler is EventNotificationScheduler) {
      scheduler.onNotificationTap = (String? eventId) {
        if (eventId == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = AppRouter.navigatorKey.currentContext;
          if (context != null) {
            AppRouter.pushEventDetails(context, eventId);
          }
        });
      };
      await scheduler.initialize();
      await scheduler.requestPermissions();
    }
  }

  runApp(const ProviderScope(child: MyApp()));

  // Handle cold start from notification tap (onDidReceiveNotificationResponse
  // does not fire when app was killed).
  if (!kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final details = await FlutterLocalNotificationsPlugin()
          .getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true) {
        final payload = details?.notificationResponse?.payload;
        final eventId = EventNotificationScheduler.getEventIdFromPayload(payload);
        if (eventId != null) {
          final context = AppRouter.navigatorKey.currentContext;
          if (context != null) {
            AppRouter.pushEventDetails(context, eventId);
          }
        }
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MerryMakin',
      // theme: ProThemes.themes[ProThemeType.midnight]!.theme,
      // darkTheme: ProThemes.themes[ProThemeType.midnight]!.theme,
      // themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}
