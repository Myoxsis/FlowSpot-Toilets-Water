import 'package:flutter/material.dart';

import '../services/onboarding_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  final _store = OnboardingStore();
  int _index = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.map_outlined,
      title: 'Find essentials nearby',
      description: 'Quickly locate public toilets and drinking fountains around you.',
    ),
    _OnboardingPageData(
      icon: Icons.verified_outlined,
      title: 'Trust what you see',
      description: 'Use recent verification, cleanliness, and reliability signals to choose faster.',
    ),
    _OnboardingPageData(
      icon: Icons.volunteer_activism_outlined,
      title: 'Help improve the city',
      description: 'Confirm spots, add reviews, earn points, and make the map more useful for everyone.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _store.markSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => _OnboardingPage(data: _pages[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _index == index ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: _index == index ? AppColors.primary : AppColors.surfaceMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Start exploring' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.12),
          ),
          child: Icon(data.icon, size: 48, color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          data.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}
