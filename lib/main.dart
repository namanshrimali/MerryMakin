import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/db/sql_lite.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:sqflite/sqflite.dart';
import 'package:merrymakin/commons/utils/platform_web.dart'
    if (dart.library.io) 'package:merrymakin/commons/utils/platform_stub.dart'
    as platform;

Future<void> main() async {
  // Initialize the Database
  WidgetsFlutterBinding.ensureInitialized();
  platform.setUrlStrategyForPlatform();
  if (kIsWeb) {
    AppFactory.forFirstTimeWeb();
  } else {
    SQLiteDBHelper dbHelper = SQLiteDBHelper.instance;
    Database database = await dbHelper.database;
    AppFactory.forFirstTimeMobile(database);
  }

  runApp(const ProviderScope(child: MyApp()));
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
