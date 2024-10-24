import 'package:efeone_mobile/controllers/checkin_permission.dart';
import 'package:efeone_mobile/controllers/home.dart';
import 'package:efeone_mobile/controllers/leave_application.dart';
import 'package:efeone_mobile/controllers/login.dart';
import 'package:efeone_mobile/controllers/notification.dart';
import 'package:efeone_mobile/controllers/profile.dart';
import 'package:efeone_mobile/controllers/splash.dart';
import 'package:efeone_mobile/controllers/timesheet.dart';
import 'package:efeone_mobile/view/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
