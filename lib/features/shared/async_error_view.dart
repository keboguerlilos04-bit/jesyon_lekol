import 'package:flutter/material.dart';

/// Shown in place of a StreamBuilder's content when its snapshot carries an
/// error. Without this, a bare `if (!snapshot.hasData) return
/// CircularProgressIndicator()` spins forever on any stream error (most
/// commonly a missing Firestore composite index) with no indication
/// anything is wrong — `hasData` never becomes true, and `hasError` was
/// never checked.
class AsyncErrorView extends StatelessWidget {
  const AsyncErrorView({super.key, required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 40),
            const SizedBox(height: 12),
            Text(
              'Pa kapab chaje done yo.\n$error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
