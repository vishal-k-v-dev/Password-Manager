import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:password_manager/auto_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

late SharedPreferences storedCredentials;
String? storedEmail;
String? storedPassword;

late bool isConnectedToInternet;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  storedCredentials  = await SharedPreferences.getInstance();
  storedEmail = storedCredentials.getString("email");
  storedPassword = storedCredentials.getString("password");

  isConnectedToInternet = await InternetConnectionChecker.instance.hasConnection;

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromARGB(255, 16, 16, 16),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        )
      ),
      initialRoute: !isConnectedToInternet ? '/no_network_error' : (storedEmail == null ? '/signup' : '/auto_login'),
      routes: {
        '/signup': (_) => const SignUpPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/auto_login': (_) => const AutoLogin(),
        '/no_network_error': (_) => Scaffold(body: Center(child: Text("No internet connection...")))
      },
    );
  }
}
