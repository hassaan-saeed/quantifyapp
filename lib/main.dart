import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Views/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(color: Colors.black, foregroundColor: Colors.amberAccent, elevation: 0),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white60
    ),
    colorScheme: const ColorScheme.dark(
        primary: Colors.amber,
        onPrimary: Colors.black,
        secondary: Colors.redAccent,
        onSecondary: Colors.white));

final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    backgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(color: Colors.white, foregroundColor: Colors.lightBlueAccent, elevation: 0),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black54
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.yellow,
      selectionColor: Colors.green,
      selectionHandleColor: Colors.blue,
    ),
    colorScheme: const ColorScheme.light(
      background: Colors.white,
      primary: Colors.lightBlueAccent,
      onPrimary: Colors.white,
      secondary: Colors.redAccent,
      onSecondary: Colors.black,
    ));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quantify',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const Login(title: 'Quantify'),
      debugShowCheckedModeBanner: false,
    );
  }
}
