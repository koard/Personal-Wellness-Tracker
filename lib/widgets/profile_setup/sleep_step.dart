import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';
import '../../models/user_profile_model.dart';

class SleepStep extends ConsumerStatefulWidget {
  const SleepStep({super.key});

  @override
  ConsumerState<SleepStep> createState() => _SleepStepState();
}

class _SleepStepState extends ConsumerState<SleepStep> {
  int _targetSleepHours = 0; // ไม่มีค่าเริ่มต้น ให้ผู้ใช้เลือก
  TimeOfDay _preferredBedtime = const TimeOfDay(hour: 0, minute: 0); // ให้ผู้ใช้เลือกเอง
  TimeOfDay _preferredWakeup = const TimeOfDay(hour: 0, minute: 0); // ให้ผู้ใช้เลือกเอง
  int _currentSleepQuality = 0; // ไม่มีค่าเริ่มต้น
  List<String> _sleepChallenges = [];

  final List<SleepChallengeOption> _sleepChallengeOptions = [
    SleepChallengeOption(
      id: 'fall_asleep',
      title: 'Hard to fall asleep',
      description: 'Takes a long time to drift off',
      icon: Icons.bedtime_outlined,
      color: const Color(0xFF6366F1),
    ),
    SleepChallengeOption(
      id: 'wake_frequently',
      title: 'Wake up frequently',
      description: 'Multiple awakenings during night',
      icon: Icons.nights_stay_outlined,
      color: const Color(0xFF8B5CF6),
    ),
    SleepChallengeOption(
      id: 'wake_tired',
      title: 'Wake up tired',
      description: 'Feel unrefreshed in the morning',
      icon: Icons.sentiment_very_dissatisfied,
      color: const Color(0xFFEF4444),
    ),
    SleepChallengeOption(
      id: 'irregular_schedule',
      title: 'Irregular schedule',
      description: 'Bedtime varies significantly',
      icon: Icons.schedule_outlined,
      color: const Color(0xFFF59E0B),
    ),
    SleepChallengeOption(
      id: 'stress_anxiety',
      title: 'Stress/Anxiety',
      description: 'Mind races when trying to sleep',
      icon: Icons.psychology_outlined,
      color: const Color(0xFFEC4899),
    ),
    SleepChallengeOption(
      id: 'environmental',
      title: 'Environmental factors',
      description: 'Noise, light, or temperature issues',
      icon: Icons.home_outlined,
      color: const Color(0xFF06B6D4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileSetupProvider).profile;
    _targetSleepHours = profile.targetSleepHours;
    _preferredBedtime = profile.preferredBedtime;
    _preferredWakeup = profile.preferredWakeup;
    _currentSleepQuality = profile.sleepPreferences.currentSleepQuality;
    _sleepChallenges = List.from(profile.sleepPreferences.sleepChallenges);
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
                        Icons.bedtime,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Let\'s optimize your rest',
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
                  'Quality sleep is the foundation of wellness. Help us create your perfect sleep routine.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Target Sleep Hours
          _buildSection(
            title: 'How many hours of sleep do you need?',
            subtitle: 'Most adults need 7-9 hours for optimal health',
            child: Container(
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
                      Text(
                        '6 hours',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '10 hours',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF8B5CF6),
                      inactiveTrackColor: const Color(0xFFE5E7EB),
                      thumbColor: const Color(0xFF8B5CF6),
                      overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _targetSleepHours.toDouble(),
                      min: 6,
                      max: 10,
                      divisions: 4,
                      onChanged: (value) {
                        setState(() {
                          _targetSleepHours = value.round();
                        });
                        ref.read(profileSetupProvider.notifier).updateSleepPreferences(
                          targetSleepHours: _targetSleepHours,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_targetSleepHours hours',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Sleep Schedule
          _buildSection(
            title: 'Preferred Sleep Schedule',
            subtitle: 'When do you like to sleep and wake up?',
            child: Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    'Bedtime',
                    _preferredBedtime,
                    Icons.bedtime,
                    const Color(0xFF6366F1),
                    (time) {
                      setState(() {
                        _preferredBedtime = time;
                      });
                      ref.read(profileSetupProvider.notifier).updateSleepPreferences(
                        preferredBedtime: time,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(
                    'Wake up',
                    _preferredWakeup,
                    Icons.wb_sunny,
                    const Color(0xFFF59E0B),
                    (time) {
                      setState(() {
                        _preferredWakeup = time;
                      });
                      ref.read(profileSetupProvider.notifier).updateSleepPreferences(
                        preferredWakeup: time,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Current Sleep Quality
          _buildSection(
            title: 'How would you rate your current sleep quality?',
            subtitle: 'Be honest - we\'ll help you improve it',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      final isSelected = _currentSleepQuality == rating;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentSleepQuality = rating;
                          });
                          _updateSleepPreferences();
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF8B5CF6) 
                                    : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getSleepQualityIcon(rating),
                                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getSleepQualityLabel(rating),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected 
                                    ? const Color(0xFF8B5CF6) 
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Sleep Challenges
          _buildSection(
            title: 'What challenges do you face with sleep?',
            subtitle: 'Select all that apply (optional)',
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _sleepChallengeOptions.length,
              itemBuilder: (context, index) {
                final challenge = _sleepChallengeOptions[index];
                return _buildSleepChallengeCard(challenge);
              },
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

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    IconData icon,
    Color color,
    Function(TimeOfDay) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: color,
                ),
              ),
              child: child!,
            );
          },
        );
        if (newTime != null) {
          onChanged(newTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChallengeCard(SleepChallengeOption challenge) {
    final isSelected = _sleepChallenges.contains(challenge.id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _sleepChallenges.remove(challenge.id);
          } else {
            _sleepChallenges.add(challenge.id);
          }
        });
        _updateSleepPreferences();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? challenge.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? challenge.color : const Color(0xFFE5E7EB),
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
                color: isSelected ? challenge.color : challenge.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                challenge.icon,
                color: isSelected ? Colors.white : challenge.color,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              challenge.title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? challenge.color : const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              challenge.description,
              style: GoogleFonts.inter(
                fontSize: 9,
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
                color: challenge.color,
                size: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSleepQualityIcon(int rating) {
    switch (rating) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getSleepQualityLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Fair';
    }
  }

  void _updateSleepPreferences() {
    final sleepPreferences = SleepPreferences(
      currentSleepQuality: _currentSleepQuality,
      sleepChallenges: _sleepChallenges,
    );
    
    ref.read(profileSetupProvider.notifier).updateSleepPreferences(
      sleepPreferences: sleepPreferences,
    );
  }
}

class SleepChallengeOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  SleepChallengeOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
