import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardData(
      image: 'lib/assets/onboarding/slide1.png',
      title: 'Track Your Wellness',
      subtitle: 'Monitor habits, sleep, mood and more.',
    ),
    _OnboardData(
      image: 'lib/assets/onboarding/slide2.png',
      title: 'Stay Hydrated',
      subtitle: 'Smart reminders help you drink enough water.',
    ),
    _OnboardData(
      image: 'lib/assets/onboarding/slide3.png',
      title: 'Achieve Your Goals',
      subtitle: 'Set targets and see your progress grow.',
    ),
  ];

  Future<void> _finish() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/profileSetup');
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final active = i == _index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? Colors.blue : Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Expanded(
                          child: Hero(
                            tag: 'onboard_image_$i',
                            child: Image.asset(p.image, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildDots(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    child: Text(last ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String image;
  final String title;
  final String subtitle;
  const _OnboardData({required this.image, required this.title, required this.subtitle});
}