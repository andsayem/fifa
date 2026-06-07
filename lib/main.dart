import 'package:fifa/common/admob_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'providers/match_provider.dart';
import 'providers/team_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/bracket_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize AdMob
  await MobileAds.instance.initialize();
  final adHelper = AdmobHelper();
  WidgetsBinding.instance.addObserver(adHelper);
  adHelper.loadAppOpenAd(
    onLoaded: () {
      Future.delayed(const Duration(seconds: 2), () {
        AdmobHelper.showAppOpenAd();
      });
    },
  );
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
      child: MaterialApp(
        title: 'FIFA 2026 Live',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Dynamically follows system theme
        home: const SplashScreen(),
      ),
    );
  }
}
