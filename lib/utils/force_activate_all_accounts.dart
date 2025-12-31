import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForceActivateAllAccounts {
  // Active TOUS les comptes employeurs existants - SOLUTION ULTIME
  static Future<void> activateAllEmployerAccounts() async {
    try {
      print('🔥 ACTIVATION FORCÉE DE TOUS LES COMPTES EMPLOYEURS');

      final batch = FirebaseFirestore.instance.batch();

      // Activer tous les employeurs
      final employersSnapshot =
          await FirebaseFirestore.instance.collection('employers').get();

      for (final doc in employersSnapshot.docs) {
        batch.update(doc.reference, {
          'emailVerified': true,
          'accountStatus': 'active',
          'isActive': true,
          'isVerified': true,
          'forceActivatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      print(
          '✅ TOUS LES COMPTES EMPLOYEURS ONT ÉTÉ ACTIVÉS: ${employersSnapshot.docs.length} comptes');
    } catch (e) {
      print('❌ Erreur activation forcée: $e');
    }
  }

  // Active le compte de l'utilisateur actuel immédiatement
  static Future<void> activateCurrentUserAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      print('🔥 ACTIVATION FORCÉE DU COMPTE ACTUEL: ${user.email}');

      await FirebaseFirestore.instance
          .collection('employers')
          .doc(user.uid)
          .set({
        'email': user.email,
        'emailVerified': true,
        'accountStatus': 'active',
        'isActive': true,
        'isVerified': true,
        'forceActivatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ COMPTE ACTUEL ACTIVÉ AVEC FORCE');
    } catch (e) {
      print('❌ Erreur activation compte actuel: $e');
    }
  }
}
