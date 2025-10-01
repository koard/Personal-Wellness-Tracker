import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';

class AnalysisStep extends ConsumerStatefulWidget {
  const AnalysisStep({super.key});

  @override
  ConsumerState<AnalysisStep> createState() => _AnalysisStepState();
}

class _AnalysisStepState extends ConsumerState<AnalysisStep> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileSetupProvider);
    final profile = profileState.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDEF7FF), Color(0xFFB3E5FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your personalized plan',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your responses, we\'ve created a personalized wellness plan just for you!',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Profile Summary
          _buildSummaryCard(
            title: 'Profile Summary',
            icon: Icons.person,
            color: const Color(0xFF10B981),
            children: [
              _buildSummaryItem('Name', profile.name),
              _buildSummaryItem('Age', '${profile.age} years old'),
              _buildSummaryItem('Goal', _formatGoal(profile.primaryGoal)),
              _buildSummaryItem('Fitness Level', _formatFitnessLevel(profile.fitnessLevel)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Health Metrics
          _buildSummaryCard(
            title: 'Health Metrics',
            icon: Icons.favorite,
            color: const Color(0xFFEF4444),
            children: [
              _buildSummaryItem('BMR', '${profile.bmr.round()} calories/day'),
              _buildSummaryItem('TDEE', '${profile.tdee.round()} calories/day'),
              _buildSummaryItem('Water Goal', '${profile.recommendedWaterIntake.toStringAsFixed(1)}L/day'),
              _buildSummaryItem('Sleep Goal', '${profile.targetSleepHours} hours/night'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Fitness Plan
          _buildSummaryCard(
            title: 'Exercise Plan',
            icon: Icons.fitness_center,
            color: const Color(0xFF3B82F6),
            children: [
              _buildSummaryItem('Daily Time', '${profile.availableWorkoutTime} minutes'),
              _buildSummaryItem('Activities', profile.preferredActivities.join(', ')),
              _buildSummaryItem('Intensity', _formatIntensity(profile.exerciseIntensity)),
              _buildSummaryItem('Schedule', _formatSchedule(profile.workSchedule)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nutrition Plan
          _buildSummaryCard(
            title: 'Nutrition Plan',
            icon: Icons.restaurant_menu,
            color: const Color(0xFFF59E0B),
            children: [
              _buildSummaryItem('Cuisines', profile.dietaryPreferences.preferredCuisines.join(', ')),
              _buildSummaryItem('Spice Level', _formatSpiceLevel(profile.dietaryPreferences.spiceLevel)),
              _buildSummaryItem('Cooking', _formatCookingFrequency(profile.dietaryPreferences.cookingFrequency)),
              _buildSummaryItem('Restrictions', profile.dietaryPreferences.restrictions.isEmpty ? 'None' : profile.dietaryPreferences.restrictions.join(', ')),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // AI Recommendations Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3E8FF), Color(0xFFDDD6FE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI-Powered Recommendations',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecommendationPreview('📝', 'Personalized Daily Routines', 'Custom morning and evening routines tailored to your schedule'),
                const SizedBox(height: 12),
                _buildRecommendationPreview('🍽️', 'Thai Meal Suggestions', 'Weekly meal plans featuring your favorite regional cuisines'),
                const SizedBox(height: 12),
                _buildRecommendationPreview('💪', 'Adaptive Workouts', 'Exercise routines that grow with your fitness level'),
                const SizedBox(height: 12),
                _buildRecommendationPreview('🏆', 'Achievement Goals', 'Milestone tracking and celebration system'),
                const SizedBox(height: 12),
                _buildRecommendationPreview('😴', 'Sleep Optimization', 'Personalized sleep schedule and relaxation techniques'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Completion Progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF10B981),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Profile ${(profileState.completionPercentage * 100).round()}% Complete',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: profileState.completionPercentage,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ready to start your personalized wellness journey! Your AI-powered recommendations will be generated once you complete the setup.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 120), // Space for navigation buttons
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationPreview(String emoji, String title, String description) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatGoal(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'general_fitness':
        return 'General Fitness';
      case 'stress_reduction':
        return 'Stress Reduction';
      case 'better_sleep':
        return 'Better Sleep';
      case 'energy_boost':
        return 'Energy Boost';
      case 'habit_building':
        return 'Habit Building';
      default:
        return goal;
    }
  }

  String _formatFitnessLevel(String level) {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return level;
    }
  }

  String _formatIntensity(int intensity) {
    switch (intensity) {
      case 1:
        return 'Very Gentle';
      case 2:
        return 'Easy';
      case 3:
        return 'Moderate';
      case 4:
        return 'Vigorous';
      case 5:
        return 'Intense';
      default:
        return 'Moderate';
    }
  }

  String _formatSchedule(String schedule) {
    switch (schedule) {
      case 'morning':
        return 'Morning Person';
      case 'evening':
        return 'Night Owl';
      case 'flexible':
        return 'Flexible';
      case 'shift':
        return 'Shift Worker';
      default:
        return schedule;
    }
  }

  String _formatSpiceLevel(int level) {
    switch (level) {
      case 1:
        return 'Mild 🌶️';
      case 2:
        return 'Light 🌶️🌶️';
      case 3:
        return 'Medium 🌶️🌶️🌶️';
      case 4:
        return 'Hot 🌶️🌶️🌶️🌶️';
      case 5:
        return 'Extra Hot 🌶️🌶️🌶️🌶️🌶️';
      default:
        return 'Medium';
    }
  }

  String _formatCookingFrequency(String frequency) {
    switch (frequency) {
      case 'never':
        return 'Never cook';
      case 'rarely':
        return 'Rarely cook';
      case 'sometimes':
        return 'Sometimes cook';
      case 'often':
        return 'Often cook';
      case 'always':
        return 'Always cook';
      default:
        return frequency;
    }
  }
}
