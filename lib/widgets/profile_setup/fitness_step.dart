import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';

class FitnessStep extends ConsumerStatefulWidget {
  const FitnessStep({super.key});

  @override
  ConsumerState<FitnessStep> createState() => _FitnessStepState();
}

class _FitnessStepState extends ConsumerState<FitnessStep> {
  String _selectedFitnessLevel = ''; // ไม่มีการเลือกเริ่มต้น
  List<String> _selectedActivities = [];
  double _exerciseIntensity = 1.0; // เริ่มจากค่าต่ำสุด

  final List<FitnessLevelOption> _fitnessLevels = [
    FitnessLevelOption(
      id: 'beginner',
      title: 'Beginner',
      description: 'New to exercise or getting back into it',
      icon: Icons.accessibility_new,
      color: const Color(0xFF84CC16),
    ),
    FitnessLevelOption(
      id: 'intermediate',
      title: 'Intermediate',
      description: 'Exercise regularly, comfortable with basics',
      icon: Icons.trending_up,
      color: const Color(0xFF3B82F6),
    ),
    FitnessLevelOption(
      id: 'advanced',
      title: 'Advanced',
      description: 'Very active, experienced with various exercises',
      icon: Icons.emoji_events,
      color: const Color(0xFFF59E0B),
    ),
  ];

  final List<ActivityOption> _activities = [
    ActivityOption(
      id: 'walking',
      title: 'Walking/Jogging',
      description: 'Outdoor or treadmill',
      icon: Icons.directions_walk,
      color: const Color(0xFF10B981),
    ),
    ActivityOption(
      id: 'yoga',
      title: 'Yoga & Stretching',
      description: 'Flexibility and mindfulness',
      icon: Icons.self_improvement,
      color: const Color(0xFF8B5CF6),
    ),
    ActivityOption(
      id: 'bodyweight',
      title: 'Bodyweight Exercises',
      description: 'Push-ups, squats, planks',
      icon: Icons.fitness_center,
      color: const Color(0xFF3B82F6),
    ),
    ActivityOption(
      id: 'swimming',
      title: 'Swimming',
      description: 'Pool or open water',
      icon: Icons.pool,
      color: const Color(0xFF06B6D4),
    ),
    ActivityOption(
      id: 'cycling',
      title: 'Cycling',
      description: 'Bike riding or stationary',
      icon: Icons.directions_bike,
      color: const Color(0xFFF97316),
    ),
    ActivityOption(
      id: 'dancing',
      title: 'Dancing',
      description: 'Fun cardio workout',
      icon: Icons.music_note,
      color: const Color(0xFFEC4899),
    ),
    ActivityOption(
      id: 'martial_arts',
      title: 'Martial Arts',
      description: 'Muay Thai, Karate, etc.',
      icon: Icons.sports_kabaddi,
      color: const Color(0xFFEF4444),
    ),
    ActivityOption(
      id: 'team_sports',
      title: 'Team Sports',
      description: 'Football, basketball, etc.',
      icon: Icons.sports_soccer,
      color: const Color(0xFF6366F1),
    ),
    ActivityOption(
      id: 'weightlifting',
      title: 'Weight Training',
      description: 'Gym or home weights',
      icon: Icons.monitor_weight,
      color: const Color(0xFF1F2937),
    ),
    ActivityOption(
      id: 'hiking',
      title: 'Hiking',
      description: 'Nature walks and trails',
      icon: Icons.terrain,
      color: const Color(0xFF059669),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileSetupProvider).profile;
    _selectedFitnessLevel = profile.fitnessLevel;
    _selectedActivities = List.from(profile.preferredActivities);
    _exerciseIntensity = profile.exerciseIntensity.toDouble();
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
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'What activities do you enjoy?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s find activities you\'ll love and stick with',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Fitness Level Selection
          _buildSection(
            title: 'Current Fitness Level',
            subtitle: 'This helps us recommend appropriate exercises',
            child: Column(
              children: _fitnessLevels.map((level) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFitnessLevelOption(level),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Preferred Activities
          _buildSection(
            title: 'Activities You Enjoy',
            subtitle: 'Select all that interest you - we\'ll create variety in your routine',
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                return _buildActivityCard(activity);
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Exercise Intensity Preference
          _buildSection(
            title: 'Exercise Intensity Preference',
            subtitle: 'How challenging do you like your workouts?',
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gentle',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Easy pace',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Challenging',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                'Push yourself',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF3B82F6),
                          inactiveTrackColor: const Color(0xFFE5E7EB),
                          thumbColor: const Color(0xFF3B82F6),
                          overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _exerciseIntensity,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged: (value) {
                            setState(() {
                              _exerciseIntensity = value;
                            });
                            ref.read(profileSetupProvider.notifier).updateFitness(
                              exerciseIntensity: value,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...List.generate(5, (index) {
                            final isActive = index < _exerciseIntensity;
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isActive 
                                    ? const Color(0xFF3B82F6) 
                                    : const Color(0xFFE5E7EB),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getIntensityDescription(_exerciseIntensity),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3B82F6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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

  Widget _buildFitnessLevelOption(FitnessLevelOption level) {
    final isSelected = _selectedFitnessLevel == level.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFitnessLevel = level.id;
        });
        ref.read(profileSetupProvider.notifier).updateFitness(
          fitnessLevel: level.id,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? level.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? level.color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? level.color : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                level.icon,
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
                    level.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? level.color : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.description,
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
                color: level.color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityOption activity) {
    final isSelected = _selectedActivities.contains(activity.id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedActivities.remove(activity.id);
          } else {
            _selectedActivities.add(activity.id);
          }
        });
        ref.read(profileSetupProvider.notifier).updateFitness(
          preferredActivities: _selectedActivities,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? activity.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? activity.color : const Color(0xFFE5E7EB),
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
                color: isSelected ? activity.color : activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity.icon,
                color: isSelected ? Colors.white : activity.color,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              activity.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? activity.color : const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              activity.description,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                color: activity.color,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getIntensityDescription(double intensity) {
    switch (intensity.round()) {
      case 1:
        return 'Very gentle - Light stretching and walking';
      case 2:
        return 'Easy - Comfortable pace, can chat easily';
      case 3:
        return 'Moderate - Slightly challenging, can still talk';
      case 4:
        return 'Vigorous - Challenging, breathing harder';
      case 5:
        return 'Intense - Very challenging, pushing your limits';
      default:
        return 'Moderate';
    }
  }
}

class FitnessLevelOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  FitnessLevelOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ActivityOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  ActivityOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
