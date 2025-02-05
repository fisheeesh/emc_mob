import 'package:emotion_check_in_app/provider/auth_provider.dart';
import 'package:emotion_check_in_app/provider/emotion_check_in_provider.dart';
import 'package:emotion_check_in_app/provider/login_provider.dart';
import 'package:emotion_check_in_app/screens/auth/login_screen.dart';
import 'package:emotion_check_in_app/screens/main/home_screen.dart';
import 'package:emotion_check_in_app/screens/onBoard/on_boarding_screen.dart';
import 'package:emotion_check_in_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Server as global variable, so they can be access anywhere in this file.
int? isViewed;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isViewed = prefs.getInt('onBoard');

  final storage = const FlutterSecureStorage();
  final authProvider = AuthProvider();
  final loginProvider = LoginProvider();

  bool isUserLoggedIn = await loginProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => loginProvider),
        ChangeNotifierProvider(create: (_) => EmotionCheckInProvider()),
      ],
      child: MyApp(isUserLoggedIn: isUserLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isUserLoggedIn;
  const MyApp({super.key, required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATA - Emotion Check-in Application',
      theme: EAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: isViewed != 0 ? OnBoardingScreen() :  isUserLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
