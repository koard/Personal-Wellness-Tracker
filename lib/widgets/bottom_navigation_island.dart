import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';

// Provider for managing current page index
final currentPageProvider = StateProvider<int>((ref) => 0);

class BottomNavigationIsland extends ConsumerWidget {
  const BottomNavigationIsland({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentPageProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingNavItem(Icons.home, l10n.navigationHome, 0, currentIndex, ref),
          _buildFloatingNavItem(Icons.favorite, l10n.navigationHabits, 1, currentIndex, ref),
          _buildFloatingNavItem(Icons.restaurant, l10n.navigationMeals, 2, currentIndex, ref),
          _buildFloatingNavItem(Icons.trending_up, l10n.navigationProgress, 3, currentIndex, ref),
          _buildFloatingNavItem(Icons.flag, l10n.navigationGoals, 4, currentIndex, ref),
          _buildFloatingNavItem(Icons.person, l10n.navigationProfile, 5, currentIndex, ref),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(IconData icon, String label, int index, int currentIndex, WidgetRef ref) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        ref.read(currentPageProvider.notifier).state = index;
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[400],
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[400],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
