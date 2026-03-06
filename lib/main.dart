import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/requests_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  RequestsStore.instance.startPolling();
  runApp(const RedLinkApp());
}

class RedLinkApp extends StatelessWidget {
  const RedLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RedLink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
