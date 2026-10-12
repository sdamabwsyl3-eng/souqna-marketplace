import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/nafath_login_screen.dart';

void main() {
  runApp(const SouqnaApp());
}

class SouqnaApp extends StatelessWidget {
  const SouqnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوقنا',
      debugShowCheckedModeBanner: false,
      theme: SouqnaTheme.lightTheme,
      home: const NafathLoginScreen(),
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
