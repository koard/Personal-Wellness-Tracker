import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';

class LifestyleStep extends ConsumerStatefulWidget {
  const LifestyleStep({super.key});

  @override
  ConsumerState<LifestyleStep> createState() => _LifestyleStepState();
}

class _LifestyleStepState extends ConsumerState<LifestyleStep> {
  String _selectedWorkSchedule = 'flexible';
  int _selectedWorkoutTime = 30;
  String _selectedActivityLevel = 'lightly_active';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileSetupProvider).profile;
    _selectedWorkSchedule = profile.workSchedule;
    _selectedWorkoutTime = profile.availableWorkoutTime;
    _selectedActivityLevel = profile.activityLevel;
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
                colors: [Color(0xFFFEF3E2), Color(0xFFFED7AA)],
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
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tell us about your lifestyle',
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
                  'Help us understand your daily routine to create the perfect wellness plan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Work schedule
          _buildSection(
            title: 'What\'s your work schedule like?',
            subtitle: 'This helps us recommend the best times for activities',
            child: Column(
              children: [
                _buildWorkScheduleOption(
                  'morning',
                  'Morning Person',
                  'I\'m most active in the morning',
                  Icons.wb_sunny,
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 12),
                _buildWorkScheduleOption(
                  'evening',
                  'Night Owl',
                  'I prefer evening activities',
                  Icons.nights_stay,
                  const Color(0xFF6366F1),
                ),
                const SizedBox(height: 12),
                _buildWorkScheduleOption(
                  'flexible',
                  'Flexible',
                  'My schedule varies',
                  Icons.schedule_outlined,
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                _buildWorkScheduleOption(
                  'shift',
                  'Shift Worker',
                  'I work irregular hours',
                  Icons.access_time,
                  const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Available workout time
          _buildSection(
            title: 'How much time can you dedicate to exercise daily?',
            subtitle: 'Be realistic - we\'ll help you make the most of your time',
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTimeOption(15, '15 min', 'Quick & Easy'),
                    const SizedBox(width: 12),
                    _buildTimeOption(30, '30 min', 'Balanced'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTimeOption(45, '45 min', 'Dedicated'),
                    const SizedBox(width: 12),
                    _buildTimeOption(60, '60+ min', 'Enthusiast'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Activity level
          _buildSection(
            title: 'How would you describe your current activity level?',
            subtitle: 'This helps us set appropriate goals',
            child: Column(
              children: [
                _buildActivityLevelOption(
                  'sedentary',
                  'Sedentary',
                  'Mostly sitting, little to no exercise',
                  Icons.chair,
                  const Color(0xFFF87171),
                ),
                const SizedBox(height: 12),
                _buildActivityLevelOption(
                  'lightly_active',
                  'Lightly Active',
                  'Light exercise 1-3 days/week',
                  Icons.directions_walk,
                  const Color(0xFFFBBF24),
                ),
                const SizedBox(height: 12),
                _buildActivityLevelOption(
                  'moderately_active',
                  'Moderately Active',
                  'Moderate exercise 3-5 days/week',
                  Icons.directions_run,
                  const Color(0xFF34D399),
                ),
                const SizedBox(height: 12),
                _buildActivityLevelOption(
                  'very_active',
                  'Very Active',
                  'Intense exercise 6-7 days/week',
                  Icons.fitness_center,
                  const Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 120), // Space for navigation buttons
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildWorkScheduleOption(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedWorkSchedule == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWorkSchedule = value;
        });
        ref.read(profileSetupProvider.notifier).updateLifestyle(
          workSchedule: value,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOption(int minutes, String display, String description) {
    final isSelected = _selectedWorkoutTime == minutes;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedWorkoutTime = minutes;
          });
          ref.read(profileSetupProvider.notifier).updateLifestyle(
            availableWorkoutTime: minutes,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                display,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLevelOption(
    String value,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedActivityLevel == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedActivityLevel = value;
        });
        ref.read(profileSetupProvider.notifier).updateLifestyle(
          activityLevel: value,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
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
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
