// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../widgets/bottom_navigation_island.dart';
// import 'dashboard/dashboard_page.dart';
// import 'habits/habits_page.dart';
// import 'meals/meals_page.dart';
// import 'progress/progress_page.dart';
// import 'goals/goals_page.dart';
// import 'profile/profile_page.dart';

// class MainNavigationScreen extends ConsumerWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentIndex = ref.watch(currentPageProvider);

//     // Define the pages
//     final pages = [
//       const DashboardPage(),    // 0 - Home
//       const HabitsPage(),       // 1 - Habits  
//       const MealsPage(),        // 2 - Meals
//       const ProgressPage(),     // 3 - Progress
//       const GoalsPage(),        // 4 - Goals                    
//       const ProfilePage(),      // 5 - Profile
//     ];

//     return Scaffold(
//       body: IndexedStack(
//         index: currentIndex,
//         children: pages,
//       ),
//     );
//   }
// }
