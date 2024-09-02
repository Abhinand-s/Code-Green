import 'package:code_green/bin_details_page.dart';
import 'package:code_green/login.dart';
import 'package:code_green/splashscreen.dart';
import 'package:code_green/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code_green',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(
        child: Wrapper(),
      ),
      routes: {
        '/login': (context) => const Login(),
        '/collect': (context) => BinDetailsPage(),
      },
    );
  }
}
