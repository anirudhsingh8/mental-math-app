import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app.dart';
import 'shared/services/service_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ServiceProvider(
      child: MentalMathApp(),
    ),
  );
}
