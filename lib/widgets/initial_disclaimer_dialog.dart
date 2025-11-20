import 'package:flutter/material.dart';
import '../models/disclaimer_config.dart';
import '../utils/disclaimer_helper.dart';

/// Full-screen disclaimer dialog shown once before entering chat
/// Uses a prominent design to ensure user reads the disclaimer
class InitialDisclaimerDialog extends StatelessWidget {
  const InitialDisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon with animated scale (smaller and more elegant)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '⚠️',
                      style: TextStyle(
                        fontSize: 36,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Title (smaller and more compact)
            Text(
              DisclaimerConfig.fullDisclaimerTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Disclaimer text (more compact and elegant)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                DisclaimerConfig.fullDisclaimerText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            
            // Buttons (more modern and compact)
            Row(
              children: [
                // Decline button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 10),
                
                // Accept button
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () async {
                      // Mark disclaimer as shown
                      await DisclaimerHelper.markDisclaimerShown();
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('I Understand'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show the disclaimer dialog and return true if user accepted
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const InitialDisclaimerDialog(),
    );
    return result ?? false;
  }
}
