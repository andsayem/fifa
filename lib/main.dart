import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'providers/match_provider.dart';
import 'providers/team_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/bracket_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'presentation/controllers/purchase_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AdMob services removed
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => BracketProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: GetMaterialApp(
        title: 'FIFA 2026 Match Shedule',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        initialBinding: BindingsBuilder(() {
          Get.put(PurchaseController());
        }),
      ),
    );
  }
}
