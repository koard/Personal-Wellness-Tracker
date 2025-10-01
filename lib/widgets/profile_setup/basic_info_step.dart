import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';

class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({super.key});

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String _selectedGender = '';
  double _height = 160.0; // เริ่มจากตรงกลาง
  double _weight = 50.0; // เริ่มจากตรงกลาง
  bool _useMetric = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.watch(profileSetupProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
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
                        Icons.person_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Let\'s get to know you',
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
                  'Tell us some basic information to personalize your wellness journey',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Name field
          _buildSection(
            title: 'What should we call you?',
            child: TextField(
              controller: _nameController,
              onChanged: (value) {
                notifier.updateBasicInfo(name: value);
              },
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF6B7280),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
                errorText: state.validationErrors['name'],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Age field
          _buildSection(
            title: 'How old are you?',
            child: TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final age = int.tryParse(value) ?? 25;
                notifier.updateBasicInfo(age: age);
              },
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF1F2937),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your age',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(
                  Icons.cake_outlined,
                  color: Color(0xFF6B7280),
                ),
                suffixText: 'years',
                suffixStyle: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
                errorText: state.validationErrors['age'],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Gender selection
          _buildSection(
            title: 'Gender',
            child: Row(
              children: [
                _buildGenderOption('male', 'Male', Icons.male),
                const SizedBox(width: 12),
                _buildGenderOption('female', 'Female', Icons.female),
                const SizedBox(width: 12),
                _buildGenderOption('other', 'Other', Icons.person),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Unit toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Measurements',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUnitToggle('Metric', _useMetric),
                    _buildUnitToggle('Imperial', !_useMetric),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Height slider
          _buildSection(
            title: 'Height',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _useMetric ? 'Height (cm)' : 'Height (ft/in)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _useMetric 
                            ? '${_height.round()} cm'
                            : '${(_height * 0.0328084).toStringAsFixed(1)} ft',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  ),
                  child: Slider(
                    value: _height,
                    min: _useMetric ? 120 : 3.94,
                    max: _useMetric ? 200 : 6.56,
                    divisions: _useMetric ? 80 : 82,
                    activeColor: const Color(0xFF3B82F6),
                    inactiveColor: const Color(0xFFE5E7EB),
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                      });
                      notifier.updateBasicInfo(height: value);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Weight slider
          _buildSection(
            title: 'Weight',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _useMetric ? 'Weight (kg)' : 'Weight (lbs)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _useMetric 
                            ? '${_weight.round()} kg'
                            : '${(_weight * 2.20462).round()} lbs',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  ),
                  child: Slider(
                    value: _weight,
                    min: _useMetric ? 30 : 66,
                    max: _useMetric ? 120 : 264,
                    divisions: _useMetric ? 90 : 198,
                    activeColor: const Color(0xFF10B981),
                    inactiveColor: const Color(0xFFE5E7EB),
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                      });
                      notifier.updateBasicInfo(weight: value);
                    },
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

  Widget _buildSection({required String title, required Widget child}) {
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
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = value;
          });
          ref.read(profileSetupProvider.notifier).updateBasicInfo(gender: value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFF9FAFB),
            border: Border.all(
              color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFD1D5DB),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitToggle(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _useMetric = label == 'Metric';
          if (!_useMetric) {
            // Convert to imperial ranges
            _height = _height * 0.0328084; // cm to ft
            _weight = _weight * 2.20462; // kg to lbs
          } else {
            // Convert to metric ranges
            _height = _height / 0.0328084; // ft to cm
            _weight = _weight / 2.20462; // lbs to kg
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFF9FAFB),
          border: isSelected ? null : Border.all(
            color: const Color(0xFFD1D5DB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
