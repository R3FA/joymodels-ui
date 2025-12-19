import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/view_model/welcome_page_view_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WelcomePageViewModel(),
      child: const JoyModelsApp(),
    ),
  );
}

class JoyModelsApp extends StatelessWidget {
  const JoyModelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WelcomePageScreen(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
    );
  }
}
