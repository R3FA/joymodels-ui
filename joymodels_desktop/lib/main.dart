import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/ui/core/themes/themes.dart';
import 'package:joymodels_desktop/ui/core/ui/loading_screen.dart';
import 'package:joymodels_desktop/ui/core/view_model/auth_view_model.dart';
import 'package:joymodels_desktop/ui/home_page/view_model/home_page_view_model.dart';
import 'package:joymodels_desktop/ui/login_page/view_model/login_page_view_model.dart';
import 'package:joymodels_desktop/ui/login_page/widgets/login_page_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 1024),
    minimumSize: Size(1024, 768),
    center: true,
    title: 'JoyModels Desktop',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(const Size(1024, 768));
    await windowManager.show();
    await windowManager.focus();
  });

  dependencyInjectionSetup();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginPageScreenViewModel()),
        ChangeNotifierProvider(create: (_) => HomePageScreenViewModel()),
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
      title: 'JoyModels Desktop',
      theme: ThemeManager.generateLightTheme(),
      darkTheme: ThemeManager.generateDarkTheme(),
      themeMode: ThemeMode.dark,
      home: FutureBuilder<Widget>(
        future: AuthViewModel.widgetHomePageScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return const LoginPageScreen();
        },
      ),
    );
  }
}
