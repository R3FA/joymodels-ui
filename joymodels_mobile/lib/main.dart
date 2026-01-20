import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/ui/core/themes/themes.dart';
import 'package:joymodels_mobile/ui/menu_drawer/view_model/menu_drawer_view_model.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/view_model/navigation_bar_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/auth_view_model.dart';
import 'package:joymodels_mobile/ui/home_page/view_model/home_page_view_model.dart';
import 'package:joymodels_mobile/ui/login_page/view_model/login_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_create_page/view_model/model_create_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_search_page/view_model/model_search_page_view_model.dart';
import 'package:joymodels_mobile/ui/register_page/view_model/register_page_view_model.dart';
import 'package:joymodels_mobile/ui/settings_page/view_model/settings_page_view_model.dart';
import 'package:joymodels_mobile/ui/verify_page/view_model/verify_page_view_model.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider(create: (_) => NavigationBarViewModel()),
        ChangeNotifierProvider(create: (_) => MenuDrawerViewModel()),
        ChangeNotifierProvider(create: (_) => HomePageScreenViewModel()),
        ChangeNotifierProvider(create: (_) => ModelSearchPageViewModel()),
        ChangeNotifierProvider(create: (_) => ModelCreatePageViewModel()),
        ChangeNotifierProvider(create: (_) => ModelPageViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsPageViewModel()),
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
      home: FutureBuilder<Widget>(
        future: AuthViewModel.widgetHomePageScreen(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return const Scaffold(body: Text("Error loading home page!"));
        },
      ),
      theme: ThemeManager.generateLightTheme(),
      darkTheme: ThemeManager.generateDarkTheme(),
      themeMode: ThemeMode.dark,
    );
  }
}
