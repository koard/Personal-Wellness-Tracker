import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int currentCalories = 1500;
  int targetCalories = 2000;
  int currentWater = 6;
  int targetWater = 8;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Greeting
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
              icon: Icon(
                    Icons.notifications,
                    color: Colors.amber,
                    size: 28,
                  ),
              onPressed: () {},
            ),
            SizedBox(width: 8),
            Icon(Icons.person, color: Colors.grey[600], size: 36),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Dashboard Title
                  Text(
                    l10n.dashboardTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Tracking Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrackingCard(
                          title: l10n.dashboardCalories,
                          current: currentCalories,
                          target: targetCalories,
                          unit: '',
                          color: Colors.orange,
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTrackingCard(
                          title: l10n.dashboardWater,
                          current: currentWater,
                          target: targetWater,
                          unit: "",
                          color: Colors.blue,
                          icon: Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Today's Activity Section
                  Text(
                    l10n.dashboardTodaysActivity,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),

                  _buildActivityCard(
                    title: l10n.dashboardOngoing,
                    subtitle: 'Go Jogging 1', // Mock data - not translated
                    time: '08:00:00',
                    status: 'ongoing',
                    duration: l10n.dashboardMinutes(150),
                  ),
                  SizedBox(height: 12),

                  _buildActivityCard(
                    title: l10n.dashboardNext,
                    subtitle: 'Yoga', // Mock data - not translated
                    time: '18:00-19:00',
                    status: 'next',
                    duration: l10n.dashboardMinutes(120),
                  ),
                  SizedBox(height: 24),

                  // Daily Habits Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.dashboardDailyHabits,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '+ ${l10n.dashboardAdd}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  _buildHabitCard(
                    'Exercise 1',
                    l10n.dashboardDaysStreak(10),
                    true,
                  ), // Mock data for exercise name
                  SizedBox(height: 8),
                  _buildHabitCard(
                    'Exercise 2',
                    l10n.dashboardDaysStreak(7),
                    false,
                  ),
                  SizedBox(height: 8),
                  _buildHabitCard(
                    'Exercise 3',
                    l10n.dashboardDaysStreak(5),
                    false,
                  ),
                  SizedBox(height: 120), // Extra space for floating nav
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard({
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    double progress = current / target;
    if (progress > 1) progress = 1;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String time,
    required String status,
    required String duration,
  }) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'ongoing' ? Colors.green[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: status == 'ongoing' ? Colors.green : Colors.blue,
                width: 1,
              ),
            ),
            child: Text(
              duration,
              style: TextStyle(
                color: status == 'ongoing'
                    ? Colors.green[700]
                    : Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(String title, String streak, bool isCompleted) {
    final l10n = AppLocalizations.of(context)!;

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  streak,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: isCompleted ? 1.0 : 0.5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : Colors.orange,
                    ),
                    strokeWidth: 5,
                  ),
                ),
                Text(
                  isCompleted ? l10n.dashboardDone : '50%',
                  style: TextStyle(
                    color: isCompleted ? Colors.green[700] : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
