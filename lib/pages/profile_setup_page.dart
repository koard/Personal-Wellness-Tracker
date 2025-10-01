import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/profile_setup_provider.dart';
import '../widgets/profile_setup/step_indicator.dart';
import '../widgets/profile_setup/basic_info_step.dart';
import '../widgets/profile_setup/lifestyle_step.dart';
import '../widgets/profile_setup/goals_step.dart';
import '../widgets/profile_setup/fitness_step.dart';
import '../widgets/profile_setup/sleep_step.dart';
import '../widgets/profile_setup/nutrition_step.dart';
import '../widgets/profile_setup/health_step.dart';
import '../widgets/profile_setup/analysis_step.dart';
import 'ai_analysis_loading_page.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  final bool isFromRegistration;
  
  const ProfileSetupPage({
    super.key,
    this.isFromRegistration = false,
  });

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupProvider);
    final setupNotifier = ref.watch(profileSetupProvider.notifier);

    // Listen for step changes and animate page transition
    ref.listen<ProfileSetupState>(profileSetupProvider, (previous, next) {
      if (previous?.currentStep != next.currentStep) {
        _pageController.animateToPage(
          next.currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation if coming from registration
        if (widget.isFromRegistration) {
          return false;
        }
        // Allow back navigation for profile editing
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Header with progress
              _buildHeader(context, setupState),
              
              // Main content area
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      BasicInfoStep(),
                      LifestyleStep(),
                      GoalsStep(),
                      FitnessStep(),
                      SleepStep(),
                      NutritionStep(),
                      HealthStep(),
                      AnalysisStep(),
                    ],
                  ),
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(context, setupState, setupNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileSetupState state) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Setup',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              // Only show close button if NOT from registration
              if (!widget.isFromRegistration)
                IconButton(
                  onPressed: () => _showExitConfirmation(context),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF6B7280),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Step indicator
          StepIndicator(
            currentStep: state.currentStep,
            totalSteps: 8,
          ),
          
          const SizedBox(height: 12),
          
          // Step title
          Text(
            _getStepTitle(state.currentStep),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ProfileSetupState state,
    ProfileSetupNotifier notifier,
  ) {
    final isLastStep = state.currentStep == 7;
    final isFirstStep = state.currentStep == 0;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: state.isLoading ? null : () {
                  notifier.previousStep();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          
          if (!isFirstStep) const SizedBox(width: 16),
          
          // Next/Complete button
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: ElevatedButton(
              onPressed: state.isLoading || state.isAnalyzing 
                  ? null 
                  : () => _handleNextButton(context, state, notifier, isLastStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: state.isAnalyzing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Analyzing...',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      isLastStep ? 'Complete Setup' : 'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Basic Information';
      case 1: return 'Lifestyle & Schedule';
      case 2: return 'Health & Wellness Goals';
      case 3: return 'Fitness Preferences';
      case 4: return 'Sleep & Recovery';
      case 5: return 'Nutrition & Diet';
      case 6: return 'Health Considerations';
      case 7: return 'AI Analysis & Confirmation';
      default: return 'Profile Setup';
    }
  }

  void _handleNextButton(
    BuildContext context,
    ProfileSetupState state,
    ProfileSetupNotifier notifier,
    bool isLastStep,
  ) {
    // Validate current step
    if (!notifier.validateCurrentStep()) {
      _showValidationError(context, state.validationErrors);
      return;
    }

    if (isLastStep) {
      // Complete profile setup
      _completeSetup(context, notifier);
    } else {
      // Move to next step
      notifier.nextStep();
    }
  }

  void _completeSetup(BuildContext context, ProfileSetupNotifier notifier) async {
    final state = ref.read(profileSetupProvider);
    
    if (widget.isFromRegistration) {
      // Navigate to AI analysis loading page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AIAnalysisLoadingPage(
            userProfile: state.profile,
          ),
        ),
      );
    } else {
      // Coming from profile edit - complete analysis inline
      await notifier.analyzeAndSaveProfile();
      
      final updatedState = ref.read(profileSetupProvider);
      if (updatedState.error != null) {
        _showErrorDialog(context, updatedState.error!);
      } else {
        // Navigate back to previous screen
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showValidationError(BuildContext context, Map<String, dynamic> errors) {
    if (errors.isEmpty) return;
    
    final firstError = errors.values.first.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(firstError),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Setup?'),
        content: const Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
