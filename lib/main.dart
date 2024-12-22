import 'package:baoudane_app/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:baoudane_app/screens/login_page.dart';
import 'package:baoudane_app/screens/register_page.dart';
import 'screens/llm_page.dart';
import 'screens/fruits_page.dart';
import 'screens/llm_speech.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter wijdane',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      //home: HomePage(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/fruits': (context) => FruitsPage(),
        '/llm': (context) => LlmPage(),
        '/assistant': (context) => AssistantPage(),
      },
    );
  }
}
