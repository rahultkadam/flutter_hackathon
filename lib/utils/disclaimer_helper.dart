import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disclaimer_config.dart';

/// Helper class for managing disclaimer-related logic
class DisclaimerHelper {
  /// Check if the user query contains high-risk financial keywords
  /// Returns true if any high-risk keyword is detected
  static bool containsHighRiskQuery(String query) {
    if (query.isEmpty) return false;
    
    // Convert query to lowercase for case-insensitive matching
    final lowerQuery = query.toLowerCase();
    
    // Check if any high-risk keyword is present in the query
    for (final keyword in DisclaimerConfig.allHighRiskKeywords) {
      if (lowerQuery.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Check if the initial disclaimer has been shown to the user
  /// Uses SharedPreferences to persist this information
  static Future<bool> hasShownDisclaimer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(DisclaimerConfig.disclaimerShownKey) ?? false;
    } catch (e) {
      debugPrint('Error checking disclaimer status: $e');
      return false;
    }
  }
  
  /// Mark that the disclaimer has been shown to the user
  /// Persists this information in SharedPreferences
  static Future<void> markDisclaimerShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(DisclaimerConfig.disclaimerShownKey, true);
    } catch (e) {
      debugPrint('Error saving disclaimer status: $e');
    }
  }
  
  /// Reset the disclaimer status (useful for testing or user preferences)
  static Future<void> resetDisclaimerStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(DisclaimerConfig.disclaimerShownKey);
    } catch (e) {
      debugPrint('Error resetting disclaimer status: $e');
    }
  }
  
  /// Show a snackbar with the disclaimer text
  /// Used when the warning icon is tapped
  static void showDisclaimerSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text(
              '⚠️',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DisclaimerConfig.fullDisclaimerText,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  /// Show a modal bottom sheet with the short disclaimer text
  /// Alternative to snackbar, more prominent
  static void showDisclaimerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Warning icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '⚠️',
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Disclaimer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Disclaimer text
            Text(
              DisclaimerConfig.fullDisclaimerText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Got it'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
