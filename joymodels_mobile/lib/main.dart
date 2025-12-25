import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/ui/core/themes/themes.dart';
import 'package:joymodels_mobile/ui/login_page/view_model/login_page_view_model.dart';
import 'package:joymodels_mobile/ui/register_page/view_model/register_page_view_model.dart';
import 'package:joymodels_mobile/ui/verify_page/view_model/verify_page_view_model.dart';
import 'package:provider/provider.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/view_model/welcome_page_view_model.dart';

void main() {
  dependencyInjectionSetup();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WelcomePageViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterPageScreenViewModel()),
        ChangeNotifierProvider(create: (_) => LoginPageScreenViewModel()),
        ChangeNotifierProvider(create: (_) => VerifyPageScreenViewModel()),
      ],
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
      theme: ThemeManager.generateLightTheme(),
      darkTheme: ThemeManager.generateDarkTheme(),
      themeMode: ThemeMode.light,
    );
  }
}
