import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:timeless/services/email_service.dart';

// This helper is used only for debugging email delivery during development.
// It lets us inspect Firestore collections related to emails and understand what happens.
class EmailDebugHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Checks the status of the most recent emails stored in the "mail" collection.
  // This is mainly used to see if emails were sent, failed, or are still pending.
  static Future<void> checkEmailStatus() async {
    try {
      final mailCollection = await _db
          .collection('mail')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      if (kDebugMode) {
        print('\n📧 === RECENT EMAIL STATUS ===');
        if (mailCollection.docs.isEmpty) {
          print('❌ No emails found in the mail collection');
        } else {
          for (var doc in mailCollection.docs) {
            final data = doc.data();
            final to = data['to'] ?? 'Unknown';
            final subject = data['message']?['subject'] ?? 'No subject';
            final delivery = data['delivery'];
            final error = data['error'];

            print('\n📧 Email ID: ${doc.id}');
            print('   To: $to');
            print('   Subject: $subject');

            if (delivery != null) {
              print(
                  '   ✅ Status: ${delivery['state']} at ${delivery['endTime']}');
            } else if (error != null) {
              print('   ❌ Error: ${error['message']}');
            } else {
              print('   ⏳ Status: Still pending...');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error while checking email status: $e');
      }
    }
  }

  // Checks the queue of emails that are waiting to be sent.
  // Useful to know if emails are blocked before being processed.
  static Future<void> checkPendingEmails() async {
    try {
      final pendingCollection = await _db
          .collection('pendingEmails')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      if (kDebugMode) {
        print('\n📫 === PENDING EMAILS ===');
        if (pendingCollection.docs.isEmpty) {
          print('✅ No pending emails in the queue');
        } else {
          for (var doc in pendingCollection.docs) {
            final data = doc.data();
            final to = data['to'];
            final subject = data['subject'];
            final status = data['status'];
            final retryCount = data['retryCount'] ?? 0;

            print('\n📫 Pending Email ID: ${doc.id}');
            print('   To: $to');
            print('   Subject: $subject');
            print('   Status: $status');
            print('   Retry Count: $retryCount');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error while checking pending emails: $e');
      }
    }
  }

  // Reads the email logs collection.
  // This helps track what happened after an email was processed.
  static Future<void> checkEmailLogs() async {
    try {
      final logsCollection = await _db
          .collection('emailLogs')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      if (kDebugMode) {
        print('\n📋 === EMAIL LOGS ===');
        if (logsCollection.docs.isEmpty) {
          print('❌ No email logs found');
        } else {
          for (var doc in logsCollection.docs) {
            final data = doc.data();
            final to = data['to'];
            final subject = data['subject'];
            final status = data['status'];
            final mailDocId = data['mailDocId'];

            print('\n📋 Log ID: ${doc.id}');
            print('   To: $to');
            print('   Subject: $subject');
            print('   Status: $status');
            print('   Mail Doc ID: $mailDocId');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error while checking email logs: $e');
      }
    }
  }

  // Runs all email checks in one place.
  // This is the main method used when debugging email issues.
  static Future<void> fullEmailCheck() async {
    if (kDebugMode) {
      print('\n🔍 === FULL EMAIL DEBUG CHECK ===');
    }

    await checkEmailStatus();
    await checkPendingEmails();
    await checkEmailLogs();

    if (kDebugMode) {
      print('\n✅ Email check completed');
      print('📧 If no email appears, verify:');
      print('   1. Firebase Extensions configuration');
      print('   2. Firestore security rules');
      print('   3. Firebase console error logs');
    }
  }

  // Sends a test email on purpose to validate the whole email pipeline.
  // Used only during development and debugging.
  static Future<void> sendTestEmail(String email) async {
    try {
      if (kDebugMode) {
        print('\n🧪 Sending test email to: $email');
      }

      final success = await EmailService.sendEmployerWelcomeEmail(
        email: email,
        fullName: 'Test Debug User',
        companyName: 'Debug Test Company',
        siretCode: '00000000000000',
      );

      if (kDebugMode) {
        if (success) {
          print('✅ Test email sent successfully');
          print('⏳ Waiting 2 seconds before checking status...');

          await Future.delayed(const Duration(seconds: 2));
          await checkEmailStatus();
        } else {
          print('❌ Failed to send test email');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error while sending test email: $e');
      }
    }
  }
}
