import 'package:aug_demo/User%20Management/User_Management.dart';
import 'package:aug_demo/User%20Management/ViewUser.dart';
import 'package:aug_demo/Augmented%20Reality/aug_real_prac.dart';
import 'package:aug_demo/Dashboards/dashboard.dart';
import 'package:aug_demo/Notification/notification_service.dart';
import 'package:aug_demo/Authentication/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toastification/toastification.dart';
import 'package:aug_demo/Augmented%20Reality/ar_homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();

  runApp(
    const ToastificationWrapper(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInScreen(),
        '/dashboard': (context) =>
            const Dashboard(isAdmin: true, iSuperAdmin: true),
        '/ar_object': (context) => const AugRealPrac(),
        '/user_manage': (context) => UserManagement(),
        '/view_user': (context) => ViewUser(),
      },
    );
  }
}
