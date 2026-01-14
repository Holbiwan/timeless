import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Quick utility to activate the current employer for testing
/// This sets isVerified=true and status='active' so jobs appear in candidate dashboard
class ActivateTestEmployer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> activate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) print('❌ No user logged in');
        return;
      }

      final employerId = user.uid;

      // Check if employer exists
      final employerDoc = await _firestore
          .collection('employers')
          .doc(employerId)
          .get();

      if (!employerDoc.exists) {
        if (kDebugMode) print('❌ Employer document not found for $employerId');
        return;
      }

      // Activate employer
      await _firestore.collection('employers').doc(employerId).update({
        'isVerified': true,
        'status': 'active',
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Employer activated: $employerId');
        print('   - isVerified: true');
        print('   - status: active');
      }

      // Also mark all jobs from this employer as verified
      final jobsSnapshot = await _firestore
          .collection('allPost')
          .where('EmployerId', isEqualTo: employerId)
          .get();

      final batch = _firestore.batch();
      for (var jobDoc in jobsSnapshot.docs) {
        batch.update(jobDoc.reference, {
          'isFromVerifiedEmployer': true,
          'employerVerifiedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (kDebugMode) {
        print('✅ ${jobsSnapshot.docs.length} jobs marked as verified');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error activating employer: $e');
    }
  }
}
