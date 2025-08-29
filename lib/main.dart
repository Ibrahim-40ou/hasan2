import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hasan2/controllers/theme_controller.dart';
import 'package:hasan2/firebase_options.dart';
import 'package:hasan2/screens/main/splash_screen.dart';
import 'package:hasan2/utils/bindings.dart';
import 'package:hasan2/utils/size_config.dart';
import 'package:hasan2/utils/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SharedPreferences? preferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dmxyakpnhgmvdgbvhbrx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRteHlha3BuaGdtdmRnYnZoYnJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0OTE4NTgsImV4cCI6MjA3MjA2Nzg1OH0.NZWBGXCCQkoV4BXiWRHYvAgFcwHFUTiolk25JqhcpXE'
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  preferences = await SharedPreferences.getInstance();

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: 100 * 1024 * 1024);

  await FirebaseFirestore.instance.enableNetwork();

  final themeController = Get.put(ThemeController());
  await themeController.loadThemeMode();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ'), Locale('fa', 'IR')],
      path: 'assets/translations',
      saveLocale: true,
      startLocale: Locale('ar', 'DZ'),
      fallbackLocale: const Locale('ar', 'DZ'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        SizeConfig().init(constraints);
        return GetBuilder<ThemeController>(
          builder: (themeController) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              home: SplashScreen(),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeController.themeMode,
              initialBinding: CustomBindings(),
            );
          },
        );
      },
    );
  }
}
