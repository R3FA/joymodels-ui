import 'package:flutter/material.dart';

void main() {
  runApp(const JoyModelsApp());
}

class JoyModelsApp extends StatelessWidget {
  const JoyModelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JoyModelsApp',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
    );
  }
}
