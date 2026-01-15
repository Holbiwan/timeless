import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// 🎬 DEMO ONLY: Auto-verify email for employer accounts
// This bypasses email verification for demo purposes
class AutoVerifyEmailForDemo {
  static Future<void> verifyCurrentUser() async {
    if (!kDebugMode) return; // Only in debug mode

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check if email is already verified
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && !updatedUser.emailVerified) {
        if (kDebugMode) {
          print('\n🎬 DEMO MODE: Auto-verifying email for ${user.email}');
          print('⚠️  WARNING: This is for demo purposes only!');
          print('   In production, users should verify their email properly.\n');
        }

        // Note: We cannot programmatically set emailVerified to true
        // The only way is to actually send and verify the email
        // For demo purposes, we'll just log this and skip verification checks
      }
    } catch (e) {
      if (kDebugMode) print('❌ Auto-verify error: $e');
    }
  }

  // Check if we should skip email verification (for demo)
  static bool shouldSkipVerification() {
    return kDebugMode; // Skip verification in debug mode
  }
}
