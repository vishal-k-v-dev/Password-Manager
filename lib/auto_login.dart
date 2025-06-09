import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {
  Future<void> autoLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: storedEmail!,
        password: storedPassword!,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Logging in...")),
    );
  }
}