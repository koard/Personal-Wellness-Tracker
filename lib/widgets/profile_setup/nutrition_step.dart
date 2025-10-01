import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/profile_setup_provider.dart';
import '../../models/user_profile_model.dart';

class NutritionStep extends ConsumerStatefulWidget {
  const NutritionStep({super.key});

  @override
  ConsumerState<NutritionStep> createState() => _NutritionStepState();
}

class _NutritionStepState extends ConsumerState<NutritionStep> {
  List<String> _dietaryRestrictions = [];
  List<String> _preferredCuisines = [];
  int _spiceLevel = 3;
  String _cookingFrequency = 'sometimes';
  List<String> _allergies = [];
  bool _hasAllergies = false;

  final List<DietaryOption> _dietaryOptions = [
    DietaryOption(
      id: 'none',
      title: 'No Restrictions',
      description: 'I eat everything',
      icon: Icons.restaurant,
      color: const Color(0xFF10B981),
    ),
    DietaryOption(
      id: 'vegetarian',
      title: 'Vegetarian',
      description: 'No meat, but dairy/eggs OK',
      icon: Icons.eco,
      color: const Color(0xFF84CC16),
    ),
    DietaryOption(
      id: 'vegan',
      title: 'Vegan',
      description: 'No animal products',
      icon: Icons.grass,
      color: const Color(0xFF059669),
    ),
    DietaryOption(
      id: 'pescatarian',
      title: 'Pescatarian',
      description: 'Fish/seafood but no meat',
      icon: Icons.set_meal,
      color: const Color(0xFF06B6D4),
    ),
    DietaryOption(
      id: 'halal',
      title: 'Halal',
      description: 'Islamic dietary guidelines',
      icon: Icons.food_bank,
      color: const Color(0xFF8B5CF6),
    ),
    DietaryOption(
      id: 'low_carb',
      title: 'Low Carb',
      description: 'Limiting carbohydrates',
      icon: Icons.no_food,
      color: const Color(0xFFF59E0B),
    ),
  ];

  final List<ThaiCuisineOption> _thaiCuisines = [
    ThaiCuisineOption(
      id: 'central',
      title: 'Central Thai',
      description: 'Pad Thai, Tom Yum, Green Curry',
      icon: '🍜',
      color: const Color(0xFF3B82F6),
    ),
    ThaiCuisineOption(
      id: 'northern',
      title: 'Northern Thai',
      description: 'Khao Soi, Sai Ua, Nam Prik',
      icon: '🍲',
      color: const Color(0xFF059669),
    ),
    ThaiCuisineOption(
      id: 'northeastern',
      title: 'Northeastern (Isaan)',
      description: 'Som Tam, Larb, Sticky Rice',
      icon: '🥗',
      color: const Color(0xFFEF4444),
    ),
    ThaiCuisineOption(
      id: 'southern',
      title: 'Southern Thai',
      description: 'Gaeng Som, Satay, Coconut dishes',
      icon: '🥥',
      color: const Color(0xFFF59E0B),
    ),
  ];

  final List<CookingFrequencyOption> _cookingOptions = [
    CookingFrequencyOption(
      id: 'never',
      title: 'Never',
      description: 'Always eat out or order',
      icon: Icons.delivery_dining,
      color: const Color(0xFFEF4444),
    ),
    CookingFrequencyOption(
      id: 'rarely',
      title: 'Rarely',
      description: '1-2 times per week',
      icon: Icons.restaurant_menu,
      color: const Color(0xFFF59E0B),
    ),
    CookingFrequencyOption(
      id: 'sometimes',
      title: 'Sometimes',
      description: '3-4 times per week',
      icon: Icons.kitchen,
      color: const Color(0xFF3B82F6),
    ),
    CookingFrequencyOption(
      id: 'often',
      title: 'Often',
      description: '5-6 times per week',
      icon: Icons.restaurant,
      color: const Color(0xFF10B981),
    ),
    CookingFrequencyOption(
      id: 'always',
      title: 'Always',
      description: 'Every day at home',
      icon: Icons.home_filled,
      color: const Color(0xFF8B5CF6),
    ),
  ];

  final List<String> _commonAllergies = [
    'Peanuts',
    'Tree nuts',
    'Shellfish',
    'Fish',
    'Eggs',
    'Dairy',
    'Soy',
    'Wheat/Gluten',
    'Sesame',
    'MSG',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileSetupProvider).profile;
    final dietaryPrefs = profile.dietaryPreferences;
    
    _dietaryRestrictions = List.from(dietaryPrefs.restrictions);
    _preferredCuisines = List.from(dietaryPrefs.preferredCuisines);
    _spiceLevel = dietaryPrefs.spiceLevel;
    _cookingFrequency = dietaryPrefs.cookingFrequency;
    _allergies = List.from(dietaryPrefs.allergies);
    _hasAllergies = _allergies.isNotEmpty;
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
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Food preferences & nutrition',
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
                  'Tell us about your eating habits and Thai food preferences for personalized meal recommendations',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Dietary Restrictions
          _buildSection(
            title: 'Dietary Restrictions',
            subtitle: 'Select all that apply to you',
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _dietaryOptions.length,
              itemBuilder: (context, index) {
                final option = _dietaryOptions[index];
                return _buildDietaryCard(option);
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Thai Cuisine Preferences
          _buildSection(
            title: 'Thai Regional Cuisines',
            subtitle: 'Which Thai regional foods do you enjoy? (Select all that apply)',
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _thaiCuisines.length,
              itemBuilder: (context, index) {
                final cuisine = _thaiCuisines[index];
                return _buildThaiCuisineCard(cuisine);
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Spice Level
          _buildSection(
            title: 'Spice Tolerance',
            subtitle: 'How spicy do you like your food?',
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
                        'Mild 🌶️',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        'Very Spicy 🌶️🌶️🌶️🌶️🌶️',
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
                      activeTrackColor: const Color(0xFFEF4444),
                      inactiveTrackColor: const Color(0xFFE5E7EB),
                      thumbColor: const Color(0xFFEF4444),
                      overlayColor: const Color(0xFFEF4444).withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _spiceLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        setState(() {
                          _spiceLevel = value.round();
                        });
                        _updateDietaryPreferences();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getSpiceLevelDescription(_spiceLevel),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Cooking Frequency
          _buildSection(
            title: 'How often do you cook at home?',
            subtitle: 'This helps us suggest appropriate recipes',
            child: Column(
              children: _cookingOptions.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCookingFrequencyOption(option),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Allergies
          _buildSection(
            title: 'Food Allergies',
            subtitle: 'Important for meal safety and recommendations',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _hasAllergies,
                      onChanged: (value) {
                        setState(() {
                          _hasAllergies = value ?? false;
                          if (!_hasAllergies) {
                            _allergies.clear();
                          }
                        });
                        _updateDietaryPreferences();
                      },
                      activeColor: const Color(0xFFEF4444),
                    ),
                    Text(
                      'I have food allergies',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                if (_hasAllergies) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Select your allergies:',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonAllergies.map((allergy) {
                      final isSelected = _allergies.contains(allergy);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _allergies.remove(allergy);
                            } else {
                              _allergies.add(allergy);
                            }
                          });
                          _updateDietaryPreferences();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFFEF4444).withOpacity(0.1) 
                                : const Color(0xFFF3F4F6),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFFEF4444) 
                                  : const Color(0xFFE5E7EB),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            allergy,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected 
                                  ? const Color(0xFFEF4444) 
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
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

  Widget _buildDietaryCard(DietaryOption option) {
    final isSelected = _dietaryRestrictions.contains(option.id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (option.id == 'none') {
            // If "No Restrictions" is selected, clear all others
            _dietaryRestrictions.clear();
            _dietaryRestrictions.add('none');
          } else {
            // Remove "No Restrictions" if selecting something else
            _dietaryRestrictions.remove('none');
            if (isSelected) {
              _dietaryRestrictions.remove(option.id);
            } else {
              _dietaryRestrictions.add(option.id);
            }
            // If nothing is selected, add "none" back
            if (_dietaryRestrictions.isEmpty) {
              _dietaryRestrictions.add('none');
            }
          }
        });
        _updateDietaryPreferences();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? option.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? option.color : const Color(0xFFE5E7EB),
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
                color: isSelected ? option.color : option.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                option.icon,
                color: isSelected ? Colors.white : option.color,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? option.color : const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              option.description,
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
                color: option.color,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThaiCuisineCard(ThaiCuisineOption cuisine) {
    final isSelected = _preferredCuisines.contains(cuisine.id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _preferredCuisines.remove(cuisine.id);
          } else {
            _preferredCuisines.add(cuisine.id);
          }
        });
        _updateDietaryPreferences();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? cuisine.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? cuisine.color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cuisine.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              cuisine.title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? cuisine.color : const Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              cuisine.description,
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
                color: cuisine.color,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCookingFrequencyOption(CookingFrequencyOption option) {
    final isSelected = _cookingFrequency == option.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _cookingFrequency = option.id;
        });
        _updateDietaryPreferences();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? option.color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? option.color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? option.color : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                option.icon,
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
                    option.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? option.color : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
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
                color: option.color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getSpiceLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Mild - No spice';
      case 2:
        return 'Light - Slightly spicy';
      case 3:
        return 'Medium - Moderately spicy';
      case 4:
        return 'Hot - Very spicy';
      case 5:
        return 'Extra Hot - Thai level spicy!';
      default:
        return 'Medium';
    }
  }

  void _updateDietaryPreferences() {
    final preferences = DietaryPreferences(
      restrictions: _dietaryRestrictions,
      preferredCuisines: _preferredCuisines,
      spiceLevel: _spiceLevel,
      cookingFrequency: _cookingFrequency,
      allergies: _allergies,
    );
    
    ref.read(profileSetupProvider.notifier).updateDietaryPreferences(preferences);
  }
}

class DietaryOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DietaryOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ThaiCuisineOption {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;

  ThaiCuisineOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class CookingFrequencyOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  CookingFrequencyOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
