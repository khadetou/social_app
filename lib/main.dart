import 'package:flutter/material.dart';
import 'package:socialapp/pages/home.dart';
import "package:firebase_core/firebase_core.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      primarySwatch: Colors.deepPurple,
    );
    return MaterialApp(
      title: "Social network app",
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(secondary: Colors.teal),
      ),
      home: const Home(),
    );
  }
}
