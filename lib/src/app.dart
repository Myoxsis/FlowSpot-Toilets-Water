import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/onboarding_store.dart';
import 'theme/app_theme.dart';

class FlowSpotApp extends StatelessWidget {
  const FlowSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowSpot',
      theme: buildFlowSpotTheme(),
      darkTheme: buildFlowSpotDarkTheme(),
      themeMode: ThemeMode.system,
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  final _store = OnboardingStore();
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hasSeen = await _store.hasSeenOnboarding();
    if (!mounted) return;
    setState(() => _hasSeenOnboarding = hasSeen);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenOnboarding == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return _hasSeenOnboarding! ? const HomeScreen() : const OnboardingScreen();
  }
}
