import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentCalories = 1500;
  int targetCalories = 2000;
  int currentWater = 6;
  int targetWater = 8;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Greeting
            Text(
              'Good Morning, ${userName.toUpperCase()}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24),
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
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Dashboard',
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
                    title: 'Calories',
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
                    title: 'Water',
                    current: currentWater,
                    target: targetWater,
                    unit: 'glasses',
                    color: Colors.blue,
                    icon: Icons.water_drop,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Today's Activity Section
            Text(
              "Today's Activity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),

            _buildActivityCard(
              title: 'Ongoing',
              subtitle: 'Go Jogging 1',
              time: '08:00:00',
              status: 'ongoing',
              duration: '150 Min',
            ),
            SizedBox(height: 12),

            _buildActivityCard(
              title: 'Next',
              subtitle: 'Yoga',
              time: '18:00-19:00',
              status: 'next',
              duration: '120 Min',
            ),
            SizedBox(height: 24),

            // Daily Habits Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Habits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '+ Add',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            _buildHabitCard('Exercise 1', '10 days streak', true),
            SizedBox(height: 8),
            _buildHabitCard('Exercise 1', '10 days streak', false),
            SizedBox(height: 8),
            _buildHabitCard('Exercise 1', '10 days streak', false),
            SizedBox(height: 120), // Extra space for floating nav
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
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
            _buildFloatingNavItem(Icons.home, 'Home', 0),
            _buildFloatingNavItem(Icons.favorite, 'Habits', 1),
            _buildFloatingNavItem(Icons.restaurant, 'Meals', 2),
            _buildFloatingNavItem(Icons.trending_up, 'Progress', 3),
            _buildFloatingNavItem(Icons.person, 'Profile', 4),
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
            color: Colors.black.withOpacity(0.05),
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
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
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
            color: Colors.black.withOpacity(0.05),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    fontWeight: FontWeight.w500,
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Text(
              isCompleted ? 'Done' : '50%',
              style: TextStyle(
                color: isCompleted ? Colors.green[700] : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
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
