// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Synchronise l'email de l'employeur connecté
// Copie l'email de Firebase Auth vers Firestore employers collection
class SyncEmployerEmails {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Synchronise l'email pour l'employeur actuellement connecté
  static Future<void> syncCurrentEmployer() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) print('❌ Aucun utilisateur connecté');
        return;
      }

      final email = user.email;
      if (email == null || email.isEmpty) {
        if (kDebugMode) print('❌ Aucun email trouvé dans Firebase Auth');
        return;
      }

      if (kDebugMode) {
        print('\n═══════════════════════════════════════════');
        print('🔄 SYNCHRONISATION EMAIL EMPLOYEUR');
        print('═══════════════════════════════════════════');
        print('📧 Email Firebase Auth: $email');
        print('👤 UID: ${user.uid}');
      }

      // Vérifier si le document employer existe
      final employerDoc = await _firestore
          .collection('employers')
          .doc(user.uid)
          .get();

      if (!employerDoc.exists) {
        if (kDebugMode) print('⚠️  Document employeur introuvable - Ce n\'est pas un compte employeur');
        return;
      }

      final currentData = employerDoc.data();
      final currentEmail = currentData?['email'];

      if (currentEmail == email) {
        if (kDebugMode) {
          print('✅ Email déjà à jour: $email');
          print('═══════════════════════════════════════════\n');
        }
        return;
      }

      // Mettre à jour l'email
      await _firestore.collection('employers').doc(user.uid).update({
        'email': email,
      });

      if (kDebugMode) {
        print('✅ Email synchronisé avec succès!');
        print('   Ancien: ${currentEmail ?? "MANQUANT"}');
        print('   Nouveau: $email');
        print('═══════════════════════════════════════════\n');
      }

      // Bonus: Mettre à jour aussi les jobs de cet employeur
      await _syncJobEmails(user.uid, email);

    } catch (e) {
      if (kDebugMode) print('❌ Erreur de synchronisation: $e');
    }
  }

  // Synchronise l'email dans tous les jobs de l'employeur
  static Future<void> _syncJobEmails(String employerId, String email) async {
    try {
      final jobsSnapshot = await _firestore
          .collection('allPost')
          .where('EmployerId', isEqualTo: employerId)
          .get();

      if (jobsSnapshot.docs.isEmpty) {
        if (kDebugMode) print('ℹ️  Aucun job trouvé pour cet employeur');
        return;
      }

      final batch = _firestore.batch();
      int updated = 0;

      for (var jobDoc in jobsSnapshot.docs) {
        final jobData = jobDoc.data();
        if (jobData['employerEmail'] != email) {
          batch.update(jobDoc.reference, {'employerEmail': email});
          updated++;
        }
      }

      if (updated > 0) {
        await batch.commit();
        if (kDebugMode) print('✅ $updated job(s) mis à jour avec le nouvel email');
      } else {
        if (kDebugMode) print('ℹ️  Tous les jobs ont déjà le bon email');
      }

    } catch (e) {
      if (kDebugMode) print('⚠️  Erreur lors de la mise à jour des jobs: $e');
    }
  }

  // Synchronise TOUS les employeurs (admin uniquement)
  static Future<void> syncAllEmployers() async {
    try {
      if (kDebugMode) {
        print('\n═══════════════════════════════════════════');
        print('🔄 SYNCHRONISATION DE TOUS LES EMPLOYEURS');
        print('═══════════════════════════════════════════\n');
      }

      final employersSnapshot = await _firestore
          .collection('employers')
          .get();

      int total = 0;
      int updated = 0;
      int skipped = 0;

      for (var doc in employersSnapshot.docs) {
        total++;
        final data = doc.data();
        final uid = doc.id;
        final currentEmail = data['email'];

        // Essayer de récupérer l'email depuis Firebase Auth
        // Note: Cette approche ne fonctionne que pour l'utilisateur connecté
        // Pour une sync complète, il faudrait une fonction Cloud
        if (currentEmail == null || (currentEmail as String).isEmpty) {
          if (kDebugMode) {
            print('⚠️  Employeur $uid: email manquant');
            print('   Nom: ${data['companyName'] ?? "N/A"}');
          }
          skipped++;
        } else {
          if (kDebugMode) print('✅ Employeur $uid: email OK ($currentEmail)');
        }
      }

      if (kDebugMode) {
        print('\n═══════════════════════════════════════════');
        print('📊 RÉSUMÉ');
        print('═══════════════════════════════════════════');
        print('Total: $total employeurs');
        print('OK: ${total - skipped} avec email');
        print('Manquants: $skipped sans email');
        print('═══════════════════════════════════════════\n');
      }

    } catch (e) {
      if (kDebugMode) print('❌ Erreur: $e');
    }
  }
}
