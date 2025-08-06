import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/meals_provider.dart';
import '../../models/meal_model.dart';
import '../../widgets/shared/image_viewer_modal.dart';
import 'camera_screen.dart';
import 'debug/debug_gemini_screen.dart';
import 'package:intl/intl.dart';

class MealsPage extends ConsumerWidget {
  const MealsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final caloriesData = ref.watch(caloriesProvider);
    final nutrientsData = ref.watch(nutrientsProvider);
    final todaysMeals = ref.watch(todaysMealsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text(
                l10n.navigationMeals,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors(context).surfaceForeground,
                ),
              ),
              backgroundColor: AppTheme.colors(
                context,
              ).surfaceBackground.withValues(alpha: 0.2),
              foregroundColor: AppTheme.colors(context).surfaceForeground,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                // Temporary debug button
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DebugGeminiScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bug_report),
                  tooltip: 'Debug Gemini API',
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calories Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.colors(
                  context,
                ).surfaceBackground.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.colors(
                    context,
                  ).surfaceForeground.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.colors(
                      context,
                    ).mutedBackground.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Today's Calories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.colors(context).surfaceForeground,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "${caloriesData['current']} / ${caloriesData['target']}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colors(context).primaryBackground,
                    ),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: caloriesData['target']! > 0
                        ? (caloriesData['current']! / caloriesData['target']!)
                              .clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor: AppTheme.colors(
                      context,
                    ).mutedBackground.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.colors(context).primaryBackground,
                    ),
                    minHeight: 8,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNutrientCard(
                        context,
                        "Carbs",
                        "${nutrientsData['carbs']!['current']!.round()}g",
                        "${nutrientsData['carbs']!['target']!.round()}g",
                        Colors.blue,
                      ),
                      _buildNutrientCard(
                        context,
                        "Protein",
                        "${nutrientsData['protein']!['current']!.round()}g",
                        "${nutrientsData['protein']!['target']!.round()}g",
                        Colors.green,
                      ),
                      _buildNutrientCard(
                        context,
                        "Fat",
                        "${nutrientsData['fat']!['current']!.round()}g",
                        "${nutrientsData['fat']!['target']!.round()}g",
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Today's Meals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Meals",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors(context).appForeground,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "+ Add Meal",
                    style: TextStyle(
                      color: AppTheme.colors(context).surfaceForeground,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Dynamic Meal Cards
            if (todaysMeals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.colors(
                    context,
                  ).surfaceBackground.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.colors(
                      context,
                    ).surfaceForeground.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.colors(
                        context,
                      ).mutedBackground.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_outlined,
                      size: 48,
                      color: AppTheme.colors(context).mutedBackground,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No meals logged today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.colors(context).surfaceForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Add Meal" to start tracking',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.colors(
                          context,
                        ).surfaceForeground.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...todaysMeals.map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMealCard(context, meal),
                ),
              ),
            SizedBox(height: 24),

            // Meal Suggestions
            Text(
              "Meal Suggestions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors(context).appForeground,
              ),
            ),
            SizedBox(height: 12),

            _buildSuggestionCard(
              context,
              "Quinoa Bowl",
              "High protein, balanced nutrients",
              "480 cal",
              Colors.teal,
            ),
            SizedBox(height: 8),
            _buildSuggestionCard(
              context,
              "Smoothie Bowl",
              "Fresh fruits and nuts",
              "320 cal",
              Colors.pink,
            ),
            SizedBox(height: 8),
            _buildSuggestionCard(
              context,
              "Avocado Toast",
              "Healthy fats and fiber",
              "280 cal",
              Colors.lime,
            ),

            SizedBox(height: 120), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientCard(
    BuildContext context,
    String name,
    String current,
    String target,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.colors(
              context,
            ).surfaceForeground.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 4),
        Text(
          current,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          "/ $target",
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.colors(
              context,
            ).surfaceForeground.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal) {
    final timeFormat = DateFormat('HH:mm');
    final time = timeFormat.format(meal.timestamp);

    // Get meal type icon and color
    IconData icon;
    Color color;

    switch (meal.mealType) {
      case 'Breakfast':
        icon = Icons.breakfast_dining;
        color = Colors.orange;
        break;
      case 'Lunch':
        icon = Icons.lunch_dining;
        color = Colors.green;
        break;
      case 'Dinner':
        icon = Icons.dinner_dining;
        color = Colors.red;
        break;
      case 'Snack':
        icon = Icons.cookie;
        color = Colors.purple;
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors(
          context,
        ).surfaceBackground.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors(
            context,
          ).surfaceForeground.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors(
              context,
            ).mutedBackground.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail image that's clickable
          GestureDetector(
            onTap: () {
              ImageViewerModal.show(
                context,
                meal.imagePath,
                '${meal.mealType} - ${meal.foodName}',
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.colors(
                    context,
                  ).surfaceForeground.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: _buildThumbnail(meal.imagePath, icon, color),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors(context).surfaceForeground,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  meal.foodName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Calories badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.colors(
                  context,
                ).surfaceForeground.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${meal.calories} cal',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String imagePath, IconData fallbackIcon, Color color) {
    final file = File(imagePath);

    if (!file.existsSync()) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Icon(fallbackIcon, color: color, size: 24),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Icon(fallbackIcon, color: color, size: 24),
        );
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    String name,
    String description,
    String calories,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors(
          context,
        ).surfaceBackground.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors(
            context,
          ).surfaceForeground.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors(
              context,
            ).mutedBackground.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: Offset(2, 0),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors(context).surfaceForeground,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.colors(
                      context,
                    ).surfaceForeground.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            calories,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
