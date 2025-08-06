import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Continuously rotate
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundImage = isDark 
        ? 'lib/assets/background-dark.png'
        : 'lib/assets/background-light.png';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Pulse Logo
              SvgPicture.asset(
                'lib/assets/pulse-logo.svg',
                width: 200,
                height: 120,
              ),
              
              // Rotating Asterisk positioned at top-right of logo
              Positioned(
                top: -30, // Adjust position relative to logo
                right: -30, // Adjust position relative to logo
                child: AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * 3.141592653589793, // 2π for full rotation
                      child: const Icon(
                        Icons.stars, // More asterisk-like icon
                        size: 28,
                        color: Color(0xFF818CF8), // Indigo color to match theme
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
