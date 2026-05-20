import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class FlowSpotApp extends StatelessWidget {
  const FlowSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowSpot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D9A8A)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
