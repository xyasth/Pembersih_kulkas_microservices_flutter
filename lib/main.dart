import 'package:flutter/material.dart';
import 'package:pembersih_kulkas_microservice_flutter/view/MainNavigation.dart';
import 'package:pembersih_kulkas_microservice_flutter/view/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pembersih Kulkas Microservice',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
