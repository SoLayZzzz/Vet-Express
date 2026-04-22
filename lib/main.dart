import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'binding.dart';
import 'themes/theme.dart';
import 'utils/app_pref.dart';
import 'utils/config.dart';
import 'utils/deep_link_handler.dart';
import 'utils/locale.dart';
import 'utils/one_signal_init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/translate.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await DeepLinkHandler.initAppLinks();

  // * Initialize SharedPreference
  await AppPref.init();

  //store cache
  await Hive.initFlutter();
  await Hive.openBox('cacheBox'); // Open a box for caching

  // * Initialize One Signal
  await initOneSignalPlatformState();

  // * Ensure Easy Localization Initialized
  await EasyLocalization.ensureInitialized();

  // * Show Status Bar After Splash Screen
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top /*, SystemUiOverlay.bottom*/],
  );

  //* Change color above navigation
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  /// Run Application
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      EasyLocalization(
        path: 'assets/locale',
        saveLocale: true,
        supportedLocales: Translate.supportedLanguage,
        startLocale: Translate.defaultLanguage,
        fallbackLocale: Translate.englishLanguage,
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child ?? const SizedBox.shrink(),
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'VET Express',
      translations: LocaleString(),
      theme: getAppTheme(context),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      initialBinding: AppBinding(),
    );
  }
}
