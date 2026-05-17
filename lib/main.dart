import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:fast_food/routes/app_routes.dart';
import 'package:fast_food/utils/constants/colors.dart';
import 'package:fast_food/utils/local_storage/storage_utility.dart';
import 'package:fast_food/utils/services/notification_service.dart';
import 'package:fast_food/utils/theme/theme.dart';

import 'bindings/general_bindings.dart';
import 'data/repositories/authentication/authentication_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Flutter bindings before any async work.
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  // // GetX Local Storage
  // await GetStorage.init();

  // Initialize YLocalStorage first
  await YLocalStorage.init('app_data');

  // Native Splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Todo: Initialize Firebase & Initialize Authentication
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthenticationRepository()));

  await YNotificationService.instance.initialize();

  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidPlayIntegrityProvider(),
    // or const AndroidDebugProvider() for testing
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fast Food',
      getPages: AppRoutes.pages,
      themeMode: ThemeMode.system,
      theme: YAppTheme.lightTheme,
      darkTheme: YAppTheme.darkTheme,
      initialBinding: GeneralBindings(),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        backgroundColor: YColors.primary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
