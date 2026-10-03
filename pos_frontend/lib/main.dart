import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/pos_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1A1A2E),
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PaytmPosApp());
}

class PaytmPosApp extends StatelessWidget {
  const PaytmPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paytm POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002970),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
      ),
      home: const PosHomeScreen(),
    );
  }
}
