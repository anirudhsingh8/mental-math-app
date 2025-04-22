import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/routes.dart';

class MentalMathApp extends StatelessWidget {
  const MentalMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Math & Brain Training',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
