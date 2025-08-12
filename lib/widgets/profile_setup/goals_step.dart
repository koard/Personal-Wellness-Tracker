import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';

class GoalsStep extends ConsumerStatefulWidget {
  const GoalsStep({super.key});

  @override
  ConsumerState<GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends ConsumerState<GoalsStep> {
  String _selectedPrimaryGoal = 'general_fitness';
  List<String> _selectedSecondaryGoals = [];

  final List<GoalOption> _primaryGoals = [
    GoalOption(
      id: 'weight_loss',
      title: 'Weight Loss',
      description: 'Lose weight healthily and sustainably',
      icon: Icons.trending_down,
      color: const Color(0xFFEF4444),
    ),
    GoalOption(
      id: 'muscle_gain',
      title: 'Muscle Gain',
      description: 'Build strength and muscle mass',
      icon: Icons.fitness_center,
      color: const Color(0xFF3B82F6),
    ),
    GoalOption(
      id: 'general_fitness',
      title: 'General Fitness',
      description: 'Stay active and improve overall health',
      icon: Icons.favorite,
      color: const Color(0xFF10B981),
    ),
    GoalOption(
      id: 'stress_reduction',
      title: 'Stress Reduction',
      description: 'Find calm and balance in daily life',
      icon: Icons.spa,
      color: const Color(0xFF8B5CF6),
    ),
    GoalOption(
      id: 'better_sleep',
      title: 'Better Sleep',
      description: 'Improve sleep quality and routine',
      icon: Icons.bedtime,
      color: const Color(0xFF6366F1),
    ),
    GoalOption(
      id: 'energy_boost',
      title: 'Energy Boost',
      description: 'Feel more energetic throughout the day',
      icon: Icons.bolt,
      color: const Color(0xFFF59E0B),
    ),
    GoalOption(
      id: 'habit_building',
      title: 'Habit Building',
      description: 'Create lasting healthy habits',
      icon: Icons.track_changes,
      color: const Color(0xFF06B6D4),
    ),
  ];

  final List<GoalOption> _secondaryGoals = [
    GoalOption(
      id: 'better_posture',
      title: 'Better Posture',
      description: 'Improve spine alignment',
      icon: Icons.accessibility_new,
      color: const Color(0xFF84CC16),
    ),
    GoalOption(
      id: 'flexibility',
      title: 'Flexibility',
      description: 'Increase range of motion',
      icon: Icons.self_improvement,
      color: const Color(0xFFF97316),
    ),
    GoalOption(
      id: 'endurance',
      title: 'Endurance',
      description: 'Build cardiovascular fitness',
      icon: Icons.directions_run,
      color: const Color(0xFFEC4899),
    ),
    GoalOption(
      id: 'mindfulness',
      title: 'Mindfulness',
      description: 'Practice meditation and awareness',
      icon: Icons.psychology,
      color: const Color(0xFF8B5CF6),
    ),
    GoalOption(
      id: 'healthy_eating',
      title: 'Healthy Eating',
      description: 'Improve nutrition habits',
      icon: Icons.restaurant_menu,
      color: const Color(0xFF059669),
    ),
    GoalOption(
      id: 'hydration',
      title: 'Better Hydration',
      description: 'Drink more water daily',
      icon: Icons.local_drink,
      color: const Color(0xFF0EA5E9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileSetupProvider).profile;
    _selectedPrimaryGoal = profile.primaryGoal;
    _selectedSecondaryGoals = List.from(profile.secondaryGoals);
  }

  @override
  Widget build(BuildContext context) {
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
                colors: [Color(0xFFECFDF5), Color(0xFFBBF7D0)],
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
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'What\'s your main wellness goal?',
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
                  'Choose your primary focus - we\'ll tailor everything to help you succeed',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Primary Goal Selection
          Text(
            'Primary Goal',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select your main focus area',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          
          // Primary Goals Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _primaryGoals.length,
            itemBuilder: (context, index) {
              final goal = _primaryGoals[index];
              return _buildPrimaryGoalCard(goal);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Secondary Goals Selection
          Text(
            'Additional Areas of Interest',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select up to 3 additional goals (optional)',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          
          // Secondary Goals Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _secondaryGoals.length,
            itemBuilder: (context, index) {
              final goal = _secondaryGoals[index];
              return _buildSecondaryGoalCard(goal);
            },
          ),
          
          if (_selectedSecondaryGoals.length >= 3) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ve selected the maximum of 3 additional goals. Remove one to select another.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 120), // Space for navigation buttons
        ],
      ),
    );
  }

  Widget _buildPrimaryGoalCard(GoalOption goal) {
    final isSelected = _selectedPrimaryGoal == goal.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrimaryGoal = goal.id;
        });
        ref.read(profileSetupProvider.notifier).updateGoals(
          primaryGoal: goal.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? goal.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? goal.color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: goal.color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? goal.color : goal.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                goal.icon,
                color: isSelected ? Colors.white : goal.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              goal.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? goal.color : const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              goal.description,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: goal.color,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryGoalCard(GoalOption goal) {
    final isSelected = _selectedSecondaryGoals.contains(goal.id);
    final canSelect = _selectedSecondaryGoals.length < 3 || isSelected;
    
    return GestureDetector(
      onTap: canSelect ? () {
        setState(() {
          if (isSelected) {
            _selectedSecondaryGoals.remove(goal.id);
          } else {
            _selectedSecondaryGoals.add(goal.id);
          }
        });
        ref.read(profileSetupProvider.notifier).updateGoals(
          secondaryGoals: _selectedSecondaryGoals,
        );
      } : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? goal.color.withOpacity(0.1) 
              : canSelect 
                  ? Colors.white 
                  : const Color(0xFFF9FAFB),
          border: Border.all(
            color: isSelected 
                ? goal.color 
                : canSelect 
                    ? const Color(0xFFE5E7EB) 
                    : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? goal.color 
                    : canSelect 
                        ? goal.color.withOpacity(0.1) 
                        : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                goal.icon,
                color: isSelected 
                    ? Colors.white 
                    : canSelect 
                        ? goal.color 
                        : const Color(0xFF9CA3AF),
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              goal.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? goal.color 
                    : canSelect 
                        ? const Color(0xFF1F2937) 
                        : const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              goal.description,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: canSelect 
                    ? const Color(0xFF6B7280) 
                    : const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                color: goal.color,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GoalOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  GoalOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
