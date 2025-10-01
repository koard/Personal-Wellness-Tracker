import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:io';
import '../../../models/meal_model.dart';
import '../../../providers/meals_provider.dart';
import '../../../widgets/shared/capsule_notification.dart';

class RecognitionScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const RecognitionScreen({super.key, required this.imagePath});

  @override
  ConsumerState<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends ConsumerState<RecognitionScreen> {
  bool _isAnalyzing = true;
  bool _isSaving = false;
  String _recognizedFood = 'Identifying...';
  int _estimatedCalories = 0;
  double _estimatedCarbs = 0.0;
  double _estimatedProtein = 0.0;
  double _estimatedFat = 0.0;
  String _selectedMealType = 'Breakfast';

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  // Text editing controllers for editable fields
  late TextEditingController _foodNameController;
  late TextEditingController _caloriesController;
  late TextEditingController _carbsController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: _recognizedFood);
    _caloriesController = TextEditingController(
      text: _estimatedCalories.toString(),
    );
    _carbsController = TextEditingController(text: _estimatedCarbs.toString());
    _proteinController = TextEditingController(
      text: _estimatedProtein.toString(),
    );
    _fatController = TextEditingController(text: _estimatedFat.toString());
    _analyzeFood();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _analyzeFood() async {
    try {
      ref.read(recognizedFoodProvider.notifier).state = 'Identifying...';

      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.analyzeFood(widget.imagePath);

      if (mounted) {
        setState(() {
          _recognizedFood = result['foodName'] ?? 'Unknown Food';
          _estimatedCalories = result['calories'] ?? 200;
          _estimatedCarbs = result['carbs'] ?? 30.0;
          _estimatedProtein = result['protein'] ?? 20.0;
          _estimatedFat = result['fat'] ?? 10.0;
          _isAnalyzing = false;
        });

        // Update the text controllers with the AI results
        _foodNameController.text = _recognizedFood;
        _caloriesController.text = _estimatedCalories.toString();
        _carbsController.text = _estimatedCarbs.round().toString();
        _proteinController.text = _estimatedProtein.round().toString();
        _fatController.text = _estimatedFat.round().toString();

        ref.read(recognizedFoodProvider.notifier).state = _recognizedFood;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recognizedFood = 'Unknown Food';
          _estimatedCalories = 200;
          _estimatedCarbs = 30.0;
          _estimatedProtein = 20.0;
          _estimatedFat = 10.0;
          _isAnalyzing = false;
        });

        // Update the text controllers with fallback values
        _foodNameController.text = _recognizedFood;
        _caloriesController.text = _estimatedCalories.toString();
        _carbsController.text = _estimatedCarbs.round().toString();
        _proteinController.text = _estimatedProtein.round().toString();
        _fatController.text = _estimatedFat.round().toString();

        CapsuleNotificationHelper.showError(
          context,
          message: 'Analysis failed. You can edit the details manually.',
        );
      }
    }
  }

  Future<void> _saveMeal() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodName: _foodNameController.text.trim().isEmpty
            ? 'Unknown Food'
            : _foodNameController.text.trim(),
        calories: int.tryParse(_caloriesController.text) ?? 200,
        carbs: double.tryParse(_carbsController.text) ?? 0.0,
        protein: double.tryParse(_proteinController.text) ?? 0.0,
        fat: double.tryParse(_fatController.text) ?? 0.0,
        imagePath: widget.imagePath,
        timestamp: DateTime.now(),
        mealType: _selectedMealType,
      );

      ref.read(mealsProvider.notifier).addMeal(meal);

      if (mounted) {
        CapsuleNotificationHelper.showSuccess(
          context,
          message: 'Meal saved successfully! 🍽️',
        );

        // Navigate back to meals page
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        CapsuleNotificationHelper.showError(
          context,
          message: 'Failed to save meal. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Food Recognition',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 24),

            // Recognition results
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAiMagic,
                        color: Colors.red,
                        size: 30.0,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Recognition',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      if (!_isAnalyzing)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isAnalyzing = true;
                            });
                            _analyzeFood();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.blue,
                            size: 20,
                          ),
                          tooltip: 'Retry AI Analysis',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isAnalyzing) ...[
                    Padding(
                      padding: const EdgeInsets.all(100.0),
                      child: Center(
                        child: Lottie.network(
                          'https://lottie.host/001ea89f-9e28-4200-a054-9a5a1932164e/gRmOdYf1zO.json',
                          width: 120,
                          height: 120,
                          repeat: true,
                          animate: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Editable food name
                    const Text(
                      'Food Name:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _foodNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter food name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Editable calories
                    const Text(
                      'Estimated Calories:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter calories',
                        suffixText: 'cal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nutrient information
                    const Text(
                      'Nutrition Information:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Carbs
                        Expanded(
                          child: TextField(
                            controller: _carbsController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              labelText: 'Carbs (g)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.green,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Protein
                        Expanded(
                          child: TextField(
                            controller: _proteinController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              labelText: 'Protein (g)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.purple,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.purple[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Fat
                        Expanded(
                          child: TextField(
                            controller: _fatController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              labelText: 'Fat (g)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can edit all nutrition information if the AI estimates need adjustment',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Meal type selection
            if (!_isAnalyzing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meal Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _mealTypes.map((type) {
                        final isSelected = type == _selectedMealType;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMealType = type;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getMealTypeIcon(type),
                                  size: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveMeal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Meal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
