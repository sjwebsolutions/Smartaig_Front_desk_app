import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:front_desk_app/services/notification_service.dart';
import 'package:front_desk_app/view/screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized in main()');
  } catch (e) {
    debugPrint('⚠️ Firebase initialize error in main(): $e');
  }

  // Initialize notifications
  NotificationService.instance.initialize().catchError((e) {
    debugPrint('⚠️ NotificationService initialization error: $e');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Front Desk App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
