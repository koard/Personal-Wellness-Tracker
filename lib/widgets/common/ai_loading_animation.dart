import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class AILoadingAnimation extends StatefulWidget {
  final String initialMessage;
  final List<String> progressMessages;
  final Duration messageDuration;

  const AILoadingAnimation({
    super.key,
    this.initialMessage = 'Analyzing with AI...',
    this.progressMessages = const [
      'Analyzing your profile...',
      'Calculating personalized recommendations...',
      'Generating meal suggestions...',
      'Creating activity plans...',
      'Optimizing for your goals...',
      'Almost ready...',
    ],
    this.messageDuration = const Duration(seconds: 3),
  });

  @override
  State<AILoadingAnimation> createState() => _AILoadingAnimationState();
}

class _AILoadingAnimationState extends State<AILoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  int _currentMessageIndex = 0;
  String _currentMessage = '';
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    
    // Initialize message
    _currentMessage = widget.initialMessage;
    
    // Start message cycling
    _startMessageCycle();
  }

  void _startMessageCycle() {
    _messageTimer = Timer.periodic(widget.messageDuration, (timer) {
      if (mounted && widget.progressMessages.isNotEmpty) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % widget.progressMessages.length;
          _currentMessage = widget.progressMessages[_currentMessageIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main loading animation
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withValues(alpha: 0.2),
                          Colors.purple.withValues(alpha: 0.2),
                          Colors.pink.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Lottie.network(
                        'https://lottie.host/001ea89f-9e28-4200-a054-9a5a1932164e/gRmOdYf1zO.json',
                        width: 80,
                        height: 80,
                        repeat: true,
                        animate: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Animated message text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _currentMessage,
              key: ValueKey(_currentMessage),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subtle progress indicator
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: null, // Indeterminate
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.withValues(alpha: 0.7),
                  ),
                  minHeight: 4,
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Secondary text
          Text(
            'This may take a few moments...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
