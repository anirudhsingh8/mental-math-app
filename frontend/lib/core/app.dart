import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/routes.dart';
import '../config/theme.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/cubit/auth_state.dart';

class MentalMathApp extends StatelessWidget {
  const MentalMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Handle authentication state changes
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(AppRoutes.navigatorKey.currentContext!)
              .pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else if (state.status == AuthStatus.authenticated) {
          Navigator.of(AppRoutes.navigatorKey.currentContext!)
              .pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
          );
        }
      },
      child: MaterialApp(
        title: 'Mental Math & Brain Training',
        navigatorKey: AppRoutes.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
