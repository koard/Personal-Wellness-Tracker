import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_navigation_island.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      appBar: AppBar(
        title: Text(
          l10n.navigationHabits,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationIsland(),
    );
  }
}
