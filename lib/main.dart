import 'package:efeone_mobile/controllers/chat.dart';
import 'package:efeone_mobile/controllers/checkin.dart';
import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/controllers/leave.dart';
import 'package:efeone_mobile/controllers/login.dart';
import 'package:efeone_mobile/controllers/notification.dart';
import 'package:efeone_mobile/controllers/profile.dart';
import 'package:efeone_mobile/controllers/splash.dart';
import 'package:efeone_mobile/controllers/task.dart';
import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/firebase_options.dart';
import 'package:efeone_mobile/utilities/firebase_api.dart';
import 'package:efeone_mobile/view/home_view.dart';
import 'package:efeone_mobile/view/login_view.dart';
import 'package:efeone_mobile/view/splash_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Splashcontroller(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginController(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomepageController(),
        ),
        ChangeNotifierProvider(
          create: (context) => Notificationcontroller(),
        ),
        ChangeNotifierProvider(
          create: (context) => Profilecontroller(),
        ),
        ChangeNotifierProvider(
          create: (context) => LeaveRequestProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CheckinPermissionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TimesheetController(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskController(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        routes: {
          "/login": (context) => Loginscreen(),
          "/home": (context) => const Homepage(),
        },
        title: 'efeone_mobile',
        theme: ThemeData(
            appBarTheme: AppBarTheme(backgroundColor: Colors.grey[100]),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[100]),
        home: const SplashScreen(),
      ),
    );
  }
}
