import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'state/trip_controller.dart';
import 'state/trip_scope.dart';
import 'theme/app_theme.dart';

class BarcelonaTripApp extends StatefulWidget {
  const BarcelonaTripApp({super.key});

  @override
  State<BarcelonaTripApp> createState() => _BarcelonaTripAppState();
}

class _BarcelonaTripAppState extends State<BarcelonaTripApp> {
  final TripController _controller = TripController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TripScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Barcelona 2026',
            theme: AppTheme.light,
            home: !_controller.initialized
                ? const _SplashScreen()
                : _controller.isLoggedIn
                    ? const ShellScreen()
                    : const LoginScreen(),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Barcelona 2026'),
          ],
        ),
      ),
    );
  }
}
