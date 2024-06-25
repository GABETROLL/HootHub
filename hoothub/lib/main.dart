// back-end
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// front-end
import 'package:flutter/material.dart';
import 'package:hoothub/screens/styles.dart';
import 'package:hoothub/screens/home/home.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: outerTheme,
      home: const Home(),
    );
  }
}
