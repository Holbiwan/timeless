import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Test direct de l'envoi d'email
  try {
    final mailDoc = await FirebaseFirestore.instance.collection("mail").add({
      "to": ["bryanomane@gmail.com"],
      "message": {
        "subject": "🧪 Test Email - Configuration SMTP",
        "html": """
          <h2>Test de Configuration Email</h2>
          <p>Si vous recevez cet email, la configuration SMTP fonctionne correctement !</p>
          <hr>
          <small>Test envoyé depuis l'app Timeless</small>
        """,
        "text": "Test de configuration email - Si vous recevez cet email, la configuration SMTP fonctionne correctement !",
      },
    });
    
    print('✅ Email de test ajouté à la queue: ${mailDoc.id}');
    print('📧 Vérifiez votre boîte mail dans quelques minutes...');
    
  } catch (e) {
    print('❌ Erreur lors du test: $e');
  }
}