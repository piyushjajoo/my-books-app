import 'package:books_app/screens/login_screen.dart';
import 'package:books_app/screens/my_books_screen.dart';
import 'package:books_app/screens/registration_screen.dart';
import 'package:books_app/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GlobalConfiguration().loadFromAsset("app_config");
  runApp(const MyBooksApp());
}

class MyBooksApp extends StatelessWidget {
  const MyBooksApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Books App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        MyBooksScreen.id: (context) => const MyBooksScreen(),
      },
    );
  }
}
