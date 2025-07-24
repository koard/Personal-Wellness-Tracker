import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // App Bar Content
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Text(
                  l10n.navigationProgress,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Body Content
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: Center(
              child: Text(
                "Progress Content Coming Soon",
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
