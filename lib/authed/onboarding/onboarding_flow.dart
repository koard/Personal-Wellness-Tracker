import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _index = 0;

  List<_OnboardData> get _pages => [
    const _OnboardData(image: 'lib/assets/onboarding/slide1.png'),
    const _OnboardData(image: 'lib/assets/onboarding/slide2.png'),
    const _OnboardData(image: 'lib/assets/onboarding/slide3.png'),
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
    // ไปหน้า Login โดยตรง เพื่อลดปัญหาลูปเมื่อเปิดโหมด force onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _skip() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarding_done', true);
    if (!mounted) return;
    // ไปหน้า Login โดยตรง เพื่อลดปัญหาลูปเมื่อเปิดโหมด force onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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
            color: active 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).primaryColor.withOpacity(0.3),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Center(
                      child: Hero(
                        tag: 'onboard_$i',
                        child: Image.asset(
                          p.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported,
                            size: 120,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildDots(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      if (_index == 0) {
                        _skip();
                      } else {
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(
                      _index == 0 ? 'Skip' : 'Back',
                      style: const TextStyle(
                        color: Colors.black87, // visible on white background
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: Text(last ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
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