import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/shared/capsule_notification.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = FirebaseAuth.instance.currentUser;
    final userAsyncValue = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.profileTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
      ),
      body: userAsyncValue.when(
        data: (user) =>
            _buildProfileContent(context, ref, authUser, user, l10n),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Error loading profile data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(currentUserProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    User? authUser,
    UserModel? user,
    AppLocalizations l10n,
  ) {
    // Use Firestore user data if available, otherwise fall back to auth user
    final displayName = user?.name ?? authUser?.displayName;
    final email = user?.email ?? authUser?.email;
    final photoURL = user?.profileImage ?? authUser?.photoURL;
    final creationTime = authUser?.metadata.creationTime;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[100],
                  child: user?.profileImage != null
                      ? ClipOval(
                          child: Image.network(
                            user!.profileImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person, size: 60, color: Colors.blue[600]),
                ),
                SizedBox(height: 16),
                Text(
                  displayName ?? l10n.profileNoDisplayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  email ?? l10n.profileNotAvailable,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // User Information Section
          Text(
            l10n.profileUserProfile,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          // Basic Information
          _buildInfoCard(
            icon: Icons.person,
            title: 'Name',
            value: displayName ?? l10n.profileNoDisplayName,
          ),
          SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.email,
            title: 'Email',
            value: email ?? l10n.profileNotAvailable,
          ),
          SizedBox(height: 12),

          if (user?.age != null) ...[
            _buildInfoCard(
              icon: Icons.cake,
              title: 'Age',
              value: '${user!.age!} years old',
            ),
            SizedBox(height: 12),
          ],

          if (user?.gender != null) ...[
            _buildInfoCard(
              icon: Icons.person_outline,
              title: 'Gender',
              value: user!.gender!.toUpperCase(),
            ),
            SizedBox(height: 12),
          ],

          // Physical Information
          if (user?.height != null || user?.weight != null) ...[
            SizedBox(height: 12),
            Text(
              'Physical Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
          ],

          if (user?.height != null) ...[
            _buildInfoCard(
              icon: Icons.height,
              title: 'Height',
              value: '${user!.height!.toStringAsFixed(0)} cm',
            ),
            SizedBox(height: 12),
          ],

          if (user?.weight != null) ...[
            _buildInfoCard(
              icon: Icons.monitor_weight,
              title: 'Weight',
              value: '${user!.weight!.toStringAsFixed(0)} kg',
            ),
            SizedBox(height: 12),
          ],

          // Goals & Preferences
          if (user?.goal != null) ...[
            SizedBox(height: 12),
            Text(
              'Goals & Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.fitness_center,
              title: 'Fitness Goal',
              value: user!.goal!,
            ),
            SizedBox(height: 12),
          ],

          // Account Information
          SizedBox(height: 12),
          Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.calendar_today,
            title: l10n.profileJoinedDate,
            value: creationTime != null
                ? _formatDate(creationTime)
                : l10n.profileNotAvailable,
          ),
          SizedBox(height: 24),

          // Settings Section
          Text(
            l10n.profileSettings,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),

          _buildSettingsCard(
            icon: Icons.language,
            title: l10n.profileChangeLanguage,
            subtitle: _getCurrentLanguageName(context),
            onTap: () => _showLanguageDialog(context, ref, l10n),
          ),
          SizedBox(height: 12),

          _buildSettingsCard(
            icon: Icons.edit,
            title: l10n.profileEditProfile,
            subtitle: "Update your personal information",
            onTap: () {
              // TODO: Navigate to edit profile screen
              CapsuleNotificationHelper.showInfo(
                context,
                message: "Edit profile feature coming soon",
              );
            },
          ),
          SizedBox(height: 12),

          // Development button to create sample data
          _buildSettingsCard(
            icon: Icons.science,
            title: "Create Sample Data",
            subtitle: "For testing Firestore integration (Dev only)",
            onTap: () async {
              if (authUser != null) {
                final success = await FirestoreService.createSampleUserData(
                  authUser.uid,
                );
                if (success) {
                  CapsuleNotificationHelper.showSuccess(
                    context,
                    message: "Sample data created successfully!",
                  );
                  // Refresh the user provider to show new data
                  ref.invalidate(currentUserProvider);
                } else {
                  CapsuleNotificationHelper.showError(
                    context,
                    message: "Failed to create sample data",
                  );
                }
              }
            },
          ),
          SizedBox(height: 12),

          _buildSettingsCard(
            icon: Icons.notifications,
            title: l10n.profileNotifications,
            subtitle: "Manage notification preferences",
            onTap: () {
              // TODO: Navigate to notifications settings
              CapsuleNotificationHelper.showInfo(
                context,
                message: "Notifications settings coming soon",
              );
            },
          ),
          SizedBox(height: 12),

          _buildSettingsCard(
            icon: Icons.privacy_tip,
            title: l10n.profilePrivacy,
            subtitle: "Privacy and security settings",
            onTap: () {
              // TODO: Navigate to privacy settings
              CapsuleNotificationHelper.showInfo(
                context,
                message: "Privacy settings coming soon",
              );
            },
          ),
          SizedBox(height: 12),

          _buildSettingsCard(
            icon: Icons.info,
            title: l10n.profileAbout,
            subtitle: "${l10n.profileVersion} 1.0.0",
            onTap: () {
              // TODO: Show about dialog
              _showAboutDialog(context, l10n);
            },
          ),
          SizedBox(height: 24),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[600],
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text(
                    l10n.profileSignOut,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 120), // Extra space for floating navigation
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
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
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getCurrentLanguageName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'th':
        return 'ไทย';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.profileChangeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.commonEnglish),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: ref.read(languageProvider).languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      ref.read(languageProvider.notifier).changeLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: Text(l10n.commonThai),
                leading: Radio<String>(
                  value: 'th',
                  groupValue: ref.read(languageProvider).languageCode,
                  onChanged: (String? value) {
                    if (value != null) {
                      ref.read(languageProvider.notifier).changeLanguage(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: "1.0.0",
      applicationIcon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.fitness_center, color: Colors.blue[600], size: 32),
      ),
      children: [
        Text(
          "A comprehensive wellness tracking application to help you maintain a healthy lifestyle.",
        ),
      ],
    );
  }
}
