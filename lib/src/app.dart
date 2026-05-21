import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class FlowSpotApp extends StatelessWidget {
  const FlowSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowSpot',
      theme: buildFlowSpotTheme(),
      home: const HomeScreen(),
    );
  }
}
