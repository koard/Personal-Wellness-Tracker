import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common/ai_loading_animation.dart';
import '../authed/authed_layout.dart';
import '../services/user_profile_service.dart';
import '../providers/profile_setup_provider.dart';
import '../providers/daily_content_provider.dart';
import '../models/user_profile_model.dart';

class AIAnalysisLoadingPage extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  
  const AIAnalysisLoadingPage({
    super.key,
    required this.userProfile,
  });
  
  @override
  ConsumerState<AIAnalysisLoadingPage> createState() => _AIAnalysisLoadingPageState();
}

class _AIAnalysisLoadingPageState extends ConsumerState<AIAnalysisLoadingPage> {
  @override
  void initState() {
    super.initState();
    // Delay the analysis to avoid modifying provider during widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }
  
  Future<void> _startAnalysis() async {
    try {
      // Perform AI analysis
      await ref.read(profileSetupProvider.notifier).analyzeAndSaveProfile();
      
      // Generate initial daily content after profile analysis
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dailyContentProvider.notifier).generateTodayContent();
      });
      
      // Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthedLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }
  
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We encountered an issue while analyzing your profile:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red[700],
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Would you like to:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startAnalysis(); // Retry
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 18, color: Colors.blue[600]),
                const SizedBox(width: 4),
                const Text('Try Again'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _skipAnalysisAndContinue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.skip_next, size: 18),
                const SizedBox(width: 4),
                const Text('Skip & Continue'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _skipAnalysisAndContinue() async {
    try {
      // Mark profile as complete without AI analysis
      await UserProfileService.markProfileComplete();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthedLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation during analysis
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const SizedBox(height: 40),
                Text(
                  'Personalizing Your Experience',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Our AI is analyzing your profile to create personalized wellness recommendations just for you.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 60),
                
                // Loading animation (avoid Expanded inside scroll views)
                const AILoadingAnimation(
                  initialMessage: 'Analyzing your profile...',
                  progressMessages: [
                    'Analyzing your profile...',
                    'Calculating your BMR and TDEE...',
                    'Creating personalized meal suggestions...',
                    'Designing your activity plans...',
                    'Optimizing for your goals...',
                    'Generating wellness insights...',
                    'Almost ready...',
                  ],
                  messageDuration: Duration(seconds: 4),
                ),
                
                const SizedBox(height: 40),
                
                // Bottom information
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.blue[600],
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI-Powered Personalization',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your responses, we\'re creating a unique wellness plan tailored to your lifestyle, goals, and preferences.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
