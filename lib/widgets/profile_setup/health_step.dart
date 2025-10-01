import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';

class HealthStep extends ConsumerStatefulWidget {
  const HealthStep({super.key});

  @override
  ConsumerState<HealthStep> createState() => _HealthStepState();
}

class _HealthStepState extends ConsumerState<HealthStep> {
  List<String> _selectedConditions = [];
  bool _hasConditions = false;
  String _physicalLimitations = '';
  bool _takesMedications = false;
  String _medicationDetails = '';
  String _previousInjuries = '';

  final List<HealthConditionOption> _healthConditions = [
    HealthConditionOption(
      id: 'diabetes',
      title: 'Diabetes',
      description: 'Type 1 or Type 2',
      icon: Icons.bloodtype,
      color: const Color(0xFFEF4444),
    ),
    HealthConditionOption(
      id: 'hypertension',
      title: 'High Blood Pressure',
      description: 'Hypertension',
      icon: Icons.favorite,
      color: const Color(0xFFDC2626),
    ),
    HealthConditionOption(
      id: 'heart_disease',
      title: 'Heart Disease',
      description: 'Cardiovascular conditions',
      icon: Icons.monitor_heart,
      color: const Color(0xFFEF4444),
    ),
    HealthConditionOption(
      id: 'asthma',
      title: 'Asthma',
      description: 'Respiratory condition',
      icon: Icons.air,
      color: const Color(0xFF3B82F6),
    ),
    HealthConditionOption(
      id: 'arthritis',
      title: 'Arthritis',
      description: 'Joint pain/stiffness',
      icon: Icons.accessibility_new,
      color: const Color(0xFFF59E0B),
    ),
    HealthConditionOption(
      id: 'back_pain',
      title: 'Back Pain',
      description: 'Chronic back issues',
      icon: Icons.accessibility,
      color: const Color(0xFF8B5CF6),
    ),
    HealthConditionOption(
      id: 'thyroid',
      title: 'Thyroid Issues',
      description: 'Hyper/hypothyroidism',
      icon: Icons.healing,
      color: const Color(0xFF10B981),
    ),
    HealthConditionOption(
      id: 'depression_anxiety',
      title: 'Depression/Anxiety',
      description: 'Mental health conditions',
      icon: Icons.psychology,
      color: const Color(0xFF6366F1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileSetupProvider).profile;
    _selectedConditions = List.from(profile.healthConditions);
    _hasConditions = _selectedConditions.isNotEmpty;
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
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Any health considerations?',
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
                  'This information helps us create safe, appropriate recommendations for your wellness journey',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Privacy Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0EA5E9)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF0EA5E9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your health information is private and secure. It\'s only used to personalize your wellness plan.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF0C4A6E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Health Conditions
          _buildSection(
            title: 'Current Health Conditions',
            subtitle: 'Select any conditions that apply (all information is optional)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _hasConditions,
                      onChanged: (value) {
                        setState(() {
                          _hasConditions = value ?? false;
                          if (!_hasConditions) {
                            _selectedConditions.clear();
                          }
                        });
                        _updateHealthInfo();
                      },
                      activeColor: const Color(0xFF10B981),
                    ),
                    Text(
                      'I have health conditions to consider',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                if (_hasConditions) ...[
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _healthConditions.length,
                    itemBuilder: (context, index) {
                      final condition = _healthConditions[index];
                      return _buildHealthConditionCard(condition);
                    },
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Physical Limitations
          _buildSection(
            title: 'Physical Limitations',
            subtitle: 'Any mobility issues or physical restrictions? (optional)',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                onChanged: (value) {
                  _physicalLimitations = value;
                  _updateHealthInfo();
                },
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Knee problems, limited mobility, recent surgery...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Medications
          _buildSection(
            title: 'Medications & Exercise',
            subtitle: 'Do you take any medications that might affect exercise? (optional)',
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _takesMedications,
                      onChanged: (value) {
                        setState(() {
                          _takesMedications = value ?? false;
                          if (!_takesMedications) {
                            _medicationDetails = '';
                          }
                        });
                        _updateHealthInfo();
                      },
                      activeColor: const Color(0xFF8B5CF6),
                    ),
                    Expanded(
                      child: Text(
                        'I take medications that may affect my exercise routine',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_takesMedications) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        _medicationDetails = value;
                        _updateHealthInfo();
                      },
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Please provide brief details about medications that may affect exercise...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Previous Injuries
          _buildSection(
            title: 'Previous Injuries',
            subtitle: 'Any past injuries we should be aware of? (optional)',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                onChanged: (value) {
                  _previousInjuries = value;
                  _updateHealthInfo();
                },
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Previous ankle sprain, shoulder injury, back problems...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Important Disclaimer',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This app provides general wellness guidance and is not a substitute for professional medical advice. Always consult your healthcare provider before starting any new exercise program, especially if you have health conditions.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF92400E),
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

  Widget _buildHealthConditionCard(HealthConditionOption condition) {
    final isSelected = _selectedConditions.contains(condition.id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedConditions.remove(condition.id);
          } else {
            _selectedConditions.add(condition.id);
          }
        });
        _updateHealthInfo();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? condition.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? condition.color : const Color(0xFFE5E7EB),
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
                color: isSelected ? condition.color : condition.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                condition.icon,
                color: isSelected ? Colors.white : condition.color,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              condition.title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? condition.color : const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              condition.description,
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
                color: condition.color,
                size: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateHealthInfo() {
    ref.read(profileSetupProvider.notifier).updateHealthConditions(_selectedConditions);
  }
}

class HealthConditionOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  HealthConditionOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
