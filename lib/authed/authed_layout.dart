import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navigation_island.dart';
import '../widgets/shared/app_background.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../pages/profile_setup_page.dart';
import 'dashboard/dashboard_page.dart';
import 'habits/habits_page.dart';
import 'meals/meals_page.dart';
import 'progress/progress_page.dart';
import 'goals/goals_page.dart';
import 'profile/profile_page.dart';

class AuthedLayout extends ConsumerStatefulWidget {
  const AuthedLayout({super.key});

  @override
  ConsumerState<AuthedLayout> createState() => _AuthedLayoutState();
}

class _AuthedLayoutState extends ConsumerState<AuthedLayout> {
  late PageController _pageController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        // 👉 ถ้ายังไม่ login ให้กลับไปหน้าหลัก (LoginScreen)
        if (user == null) {
          Future.microtask(() {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          });
          return const SizedBox(); // รอ redirect
        }

        // 🔄 Check user profile completion status
        final userAsyncValue = ref.watch(currentUserProvider);
        
        return userAsyncValue.when(
          data: (userModel) {
            // If user model exists but profile setup is not complete, redirect to profile setup
            if (userModel != null && !userModel.isProfileSetupComplete) {
              return const ProfileSetupPage();
            }

            // ✅ ถ้า login อยู่และ profile setup เสร็จแล้ว สร้างหน้าหลักตามปกติ
            final pageContents = [
              const DashboardPage(),
              const HabitsPage(),
              const MealsPage(),
              const ProgressPage(),
              const GoalsPage(),
              const ProfilePage(),
            ];

            // เช็คการเปลี่ยนหน้า
            ref.listen<int>(currentPageProvider, (previous, next) {
              if (_pageController.hasClients && previous != next && !_isAnimating) {
                _isAnimating = true;
                _pageController.animateToPage(
                  next,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ).then((_) {
                  _isAnimating = false;
                });
              }
            });

            return AppBackground(
              child: Scaffold(
                extendBody: true,
                extendBodyBehindAppBar: false,
                backgroundColor: Colors.transparent, // Make scaffold transparent to show gradient
                body: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (!_isAnimating) {
                      ref.read(currentPageProvider.notifier).state = index;
                    }
                  },
                  children: pageContents,
                ),
                bottomNavigationBar: const BottomNavigationIsland(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            // If there's an error loading user data (e.g., Firestore PERMISSION_DENIED),
            // don't force Profile Setup. Show a lightweight error with retry.
            return AppBackground(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load user data.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // trigger re-fetch
                        ref.invalidate(currentUserProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading user')),
    );
  }
}


// These are content-only versions of your pages (without Scaffold and bottomNavigationBar)
class DashboardContent extends ConsumerStatefulWidget {
  const DashboardContent({super.key});

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent>
    with TickerProviderStateMixin {
  int currentCalories = 1500;
  int targetCalories = 2000;
  int currentWater = 6;
  int targetWater = 8;
  
  // Animation controllers for progress bars
  late AnimationController _caloriesAnimationController;
  late AnimationController _waterAnimationController;
  late Animation<double> _caloriesAnimation;
  late Animation<double> _waterAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _caloriesAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create animations that go from 0 to actual progress
    _caloriesAnimation = Tween<double>(
      begin: 0.0,
      end: currentCalories / targetCalories,
    ).animate(CurvedAnimation(
      parent: _caloriesAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _waterAnimation = Tween<double>(
      begin: 0.0,
      end: currentWater / targetWater,
    ).animate(CurvedAnimation(
      parent: _waterAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _caloriesAnimationController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _waterAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _caloriesAnimationController.dispose();
    _waterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              l10n.dashboardGoodMorning(userName.toUpperCase()),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.amber),
              onPressed: () {},
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24),

            // Animated Tracking Cards Row
            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _caloriesAnimation,
                    builder: (context, child) {
                      return _buildAnimatedTrackingCard(
                        title: l10n.dashboardCalories,
                        current: currentCalories,
                        target: targetCalories,
                        unit: '',
                        color: Colors.orange,
                        icon: Icons.local_fire_department,
                        progress: _caloriesAnimation.value,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _waterAnimation,
                    builder: (context, child) {
                      return _buildAnimatedTrackingCard(
                        title: l10n.dashboardWater,
                        current: currentWater,
                        target: targetWater,
                        unit: l10n.dashboardGlasses,
                        color: Colors.blue,
                        icon: Icons.water_drop,
                        progress: _waterAnimation.value,
                      );
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 120), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTrackingCard({
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color color,
    required IconData icon,
    required double progress,
  }) {
    // Clamp progress between 0 and 1
    double clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '$current/$target',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (unit.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: clampedProgress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

// Placeholder content widgets for other pages (you'll extract these from your existing pages)
class HabitsContent extends StatelessWidget {
  const HabitsContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract the body content from HabitsPage (without Scaffold and bottomNavigationBar)
    return Center(child: Text("Habits Content"));
  }
}

class MealsContent extends StatelessWidget {
  const MealsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Meals Content"));
  }
}

class ProgressContent extends StatelessWidget {
  const ProgressContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Progress Content"));
  }
}

class GoalsContent extends StatelessWidget {
  const GoalsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Goals Content"));
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Profile Content"));
  }
}
