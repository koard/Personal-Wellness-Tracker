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

  final List<_OnboardData> _pages = const [
    _OnboardData(image: 'lib/assets/onboarding/slide1.png'),
    _OnboardData(image: 'lib/assets/onboarding/slide2.png'),
    _OnboardData(image: 'lib/assets/onboarding/slide3.png'),
  ];

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/authed', (r) => false);
  }

  Future<void> _skip() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/authed', (r) => false);
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final active = i == _index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 8,
            width: active ? 22 : 8,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF2563EB) : const Color(0xFF2563EB).withOpacity(.30),
              borderRadius: BorderRadius.circular(30),
            ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Center(
                      child: Hero(
                        tag: 'onboard_$i',
                        child: Image.asset(
                          p.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildDots(),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Skip', style: TextStyle(color: Color(0xFF475569))),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: Text(last ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String image;
  const _OnboardData({required this.image});
}